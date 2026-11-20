# RufletRecord

RufletRecord is a small SQLite record mapper for Ruflet apps. Its models,
relations and schema helpers are shaped like the core of Active Record, but it
has no Rails or ActiveSupport dependency. It ships as the `ruflet_record` gem
and runs on CRuby with the `sqlite3` gem.

A Rails app keeps using Active Record. RufletRecord is for Ruflet apps that
store data without Rails.

## Install

Add the gem to the project's `Gemfile`:

```ruby
gem "ruflet_record"
```

Run `bundle install`. The gem depends on `sqlite3` 2.0 or later, which Bundler
installs with it. `ruflet run` loads the project's bundle.

## Connect

Open the database once, before any model is used:

```ruby
require "ruflet_record"

RufletRecord.establish_connection(
  database: File.join(__dir__, "app.sqlite3"),
  journal_mode: :wal,
  timeout: 5_000
)
```

- `database` is required: a file path, or `":memory:"` for a database that lives only as long as the process, which suits tests. SQLite creates the file, but not its directory; a missing directory raises `SQLite3::CantOpenException`. A plain string is the path: `establish_connection("app.sqlite3")`.
- `foreign_keys` defaults to `true`, so SQLite enforces the foreign keys the schema declares. Pass `false` to turn that off.
- `timeout` is how long, in milliseconds, a statement waits for a lock another connection holds. It defaults to 5000.
- `journal_mode` is one of `delete`, `truncate`, `persist`, `memory`, `wal` or `off`. Without it SQLite keeps its default. Any other value raises `ArgumentError`.

`RufletRecord.connection` returns the connection and raises
`RufletRecord::ConnectionNotEstablished` before one is open. A model class
may open its own database with `Model.establish_connection(...)`; calling it
on `RufletRecord::Base` sets the shared connection. With 0.0.23 that model's
subclasses still use the shared connection.

A model's subclasses use its connection, so a parent class can hold a second
database for the models under it. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Define the schema

```ruby
RufletRecord::Schema.define do
  create_table :users, if_not_exists: true do |table|
    table.string :name, null: false
    table.string :email
    table.boolean :active, default: true
    table.timestamps
    table.index :email, unique: true
  end

  create_table :posts, if_not_exists: true do |table|
    table.references :user, null: false, foreign_key: { on_delete: :cascade }
    table.string :title, null: false
    table.text :body
    table.timestamps
  end
end
```

Every table gets an `id INTEGER PRIMARY KEY AUTOINCREMENT` column unless
`create_table` is given `id: false`. `if_not_exists: true` skips a table that
already exists, so the block can run on every start. `force: true` drops the
table and creates it again.

| Column helper | SQLite type | Read back as |
| --- | --- | --- |
| `string` | `VARCHAR` | String |
| `text` | `TEXT` | String |
| `integer` | `INTEGER` | Integer |
| `float` | `REAL` | Float |
| `decimal` | `DECIMAL` | Float |
| `boolean` | `BOOLEAN` | `true` or `false`; stored as 1 or 0 |
| `datetime` | `DATETIME` | `Time` in UTC |
| `date` | `DATE` | `Time` at midnight UTC |
| `binary` | `BLOB` | String |
| `json` | `TEXT` | String: RufletRecord does not decode it |

Times read back as UTC. With 0.0.23 a `Time` is stored as
`YYYY-MM-DD HH:MM:SS` without its offset, and a string's offset is ignored,
so write UTC times; the timestamps already are. With 0.0.23 a Hash or an
Array is not converted: saving one fails or stores the wrong value, so store a
JSON string.

A `Time` is stored as its UTC time, so it keeps its instant, and a string's
`Z` or `+HH:MM` offset is applied. A Hash or an Array is stored as JSON text,
in any column, and a hash condition such as `where(prefs: { "theme" => "dark" })`
matches that text. It reads back as the text, so call `JSON.parse` to get the
data. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

Each helper takes `null: false`, `default:` and `unique: true`.
`timestamps` adds `created_at` and `updated_at`. `references :user` (alias
`belongs_to`) adds an integer `user_id` column with an index; pass
`index: false` to skip the index or `index: { unique: true }` to change it.
`foreign_key: true` references the `users` table, and a hash may set
`to_table`, `primary_key`, `on_delete` and `on_update`, with the actions
`cascade`, `restrict`, `set_null`, `set_default` and `no_action`.
`table.index` takes a column or an array of columns, `unique:` and `name:`.

The schema block also changes existing tables:

```ruby
RufletRecord::Schema.define do
  add_column :users, :age, :integer, default: 0
  add_index :users, :age
end
```

`add_column` takes the same options as a column helper, and `add_index` takes
`unique:` and `name:`. `remove_index :users, :age` drops an index by its
columns, `rename_table :posts, :articles` renames a table, and
`drop_table :posts, if_exists: true` drops one. `RufletRecord.connection.table_exists?(:users)`
reports whether a table exists.

### Migrations

A migration class runs the same operations:

```ruby
class CreateTasks < RufletRecord::Migration
  def change
    create_table :tasks, if_not_exists: true do |table|
      table.string :title, null: false
      table.boolean :done, default: false
      table.timestamps
    end
  end
end

CreateTasks.migrate(:up)
```

`migrate(:up)` runs `up`, or `change` when the class has no `up`.
`migrate(:down)` runs `down`; a `change` is not reversed for you, and a class
without `down` raises `RufletRecord::Error`. RufletRecord does not record which
migrations have run, so write them to be safe to repeat, as with
`if_not_exists: true`.

## Models

```ruby
class User < RufletRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :email

  has_many :posts
  has_one :profile

  scope :active, -> { where(active: true) }
end

class Post < RufletRecord::Base
  belongs_to :user
end
```

A model reads its attributes from its table's columns, so create the table
before you build a record. Each column has a reader and a writer (`user.name`,
`user.name = "Ada"`), and `user[:name]`, `read_attribute`, `write_attribute`,
`attributes` and `assign_attributes` work too. A value is converted to the
column's type when it is written. Writing a column the table does not have
raises `RufletRecord::UnknownAttributeError`.

The table name is the class name in snake case with a simple plural: `Post`
is `posts`, `BlogPost` is `blog_posts`, `Category` is `categories` and `Box`
is `boxes`, but `Person` is `persons`, and with 0.0.23 `Day` is `daies`.

A `y` after a vowel stays in the plural, so `Day` is `days` and `Key` is
`keys`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

Set the table name, and the primary key, where the convention does not fit:

```ruby
class LegacyEntry < RufletRecord::Base
  self.table_name = "entries"
  self.primary_key = "entry_id"
end
```

A model caches its columns. The schema operations above refresh every model;
after changing a table with raw SQL, call `Model.reset_column_information`.

## Validations

`validates_presence_of` rejects `nil` and empty values with "can't be blank".
`validates_uniqueness_of` runs a query and rejects a value another row already
has with "has already been taken"; it has no `scope:` option. They are the
only validations: keep hard rules in the schema, as `null: false` and unique
indexes, and use these for messages people read.

```ruby
user = User.new(name: "")
user.save                  # => false
user.errors[:name]         # => ["can't be blank"]
user.errors.full_messages  # => ["Name can't be blank"]
```

`save` returns `false` when a validation fails, and also when SQLite rejects
the row, for example on a `NOT NULL` or unique constraint; the database's
message is then under `errors[:base]`. `save!` raises
`RufletRecord::RecordInvalid` (its `record` is the model) for a failed
validation and `RufletRecord::RecordNotSaved` for a database error. `valid?`
runs the validations without saving.

## Persistence

```ruby
user = User.create!(name: "Ada", email: "ada@example.com")
post = user.posts.create!(title: "Notes")

user.update!(active: false)
user.reload
user.destroy
```

- `new`, then `save` or `save!`, inserts a row; `create` and `create!` do both at once. A new record gets its `id` from SQLite.
- `update` and `update!` assign attributes and save. Saving a record that exists writes only the changed columns. `changes` lists them as `{ "name" => [old, new] }`, and `changed?` says whether there are any.
- Every save sets `updated_at`, and an insert sets `created_at` when it is empty, if the table has those columns.
- `update_columns(name: "Grace")` writes straight to the row: no validations and no `updated_at`. `touch` sets `updated_at` alone.
- `destroy` and `delete` both delete the row; there are no callbacks.
- `reload` reads the row again. `new_record?`, `persisted?` and `destroyed?` report the record's state.
- `find_or_initialize_by`, `find_or_create_by` and `find_or_create_by!` look a row up by attributes and build or create it when none matches.
- A relation also has `update_all(attributes)` and `delete_all`, which run one statement, and `destroy_all`, which loads the records and deletes each.

## Associations

- `belongs_to :user` reads `user_id` and returns the `User` with that id, or `nil`. `post.user = user` sets `user_id`. With 0.0.23 `new`, `create` and `update` take only column names, so pass `user_id: user.id` there.
- `has_many :posts` returns a relation of the posts whose `user_id` is this user's id. `user.posts.create!(...)` sets `user_id` for you.
- `has_one :profile` returns the first `Profile` whose `user_id` matches.

`Post.new(user: user)`, `create` and `update` take a `belongs_to` name too. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

Each takes `class_name:` and `foreign_key:` to override the conventions. With
0.0.23 `has_many :addresses` looks for an `Addresse` class, and `:statuses`,
`:buses` and `:aliases` miss their class the same way, so pass `class_name:`
there.

`has_many :addresses`, `:statuses`, `:buses` and `:aliases` find `Address`,
`Status`, `Bus` and `Alias`. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

A `belongs_to` or `has_one` reader looks the record up when it is called and
returns it, or `nil`. A `has_many` reader returns a new relation, which runs
its query when its records are requested. Nothing is cached or eager-loaded,
so every call looks the rows up again.

## Queries

Building a relation never touches SQLite:

```ruby
query = User.where(active: true).order(name: :asc).limit(20)
# No SQL has run yet.

users = query.to_a # SQL runs here.
```

These methods return a new relation and leave the original unchanged:

- `where`, with a hash of conditions or a SQL string and its bind values, and `where.not`
- `order` and `reorder`
- `select` and `distinct`
- `limit` and `offset`
- `joins`, which takes an explicit `JOIN` clause
- `merge`, which combines two relations of the same model
- `has_many` readers

SQL runs when records or values are requested: `each`, `to_a`, `first`,
`last`, `find`, `find_by`, `find_by!`, `pluck`, `pick`, `ids`, `count`, `sum`,
`average`, `minimum`, `maximum`, `exists?` and `find_each`. A loaded relation
keeps its records until `reload`. Writes run immediately.

```ruby
User.where("email LIKE ?", "%@example.com")
User.where(id: [1, 2, 3])
User.where(created_at: start_time..end_time)
User.where.not(active: false)
User.where(email: nil)
User.order(name: :desc).pluck(:name, :email)
```

- A hash condition matches equal values. `nil` matches `NULL`, an array matches any of its values (an empty array matches nothing), and a range `a..b` or `a...b` matches the values between its ends.
- A string condition must have one bind value per `?`; otherwise it raises `ArgumentError`.
- Values are passed to SQLite as bind parameters and identifiers are quoted. An `order` string may only name columns with an optional `ASC` or `DESC`; anything else raises `ArgumentError`. Wrap trusted SQL in `RufletRecord.sql(...)` to use it in `select`, `order` or `joins`.
- `find` raises `RufletRecord::RecordNotFound` when no row has that id, and so does `find_by!`; `find_by` returns `nil`.
- `last` orders by the primary key, whatever the relation's order. `sum` returns 0 on no rows; `average`, `minimum` and `maximum` return `nil`.
- `find_each(batch_size: 1000)` loads the rows in primary-key order, one batch at a time.
- `to_sql` and `bound_attributes` return the statement and its values without running it.

```ruby
User.select(RufletRecord.sql("COUNT(*) AS total"))
```

A `scope` defines a class method that returns a relation, so call it on the
model: `User.active.order(:name)` works, while `User.order(:name).active` does
not.

A range with an open end leaves that side unbounded, as in Active Record:
`where(age: 18..)` is `age >= 18`, `..17` is `age <= 17`, `...18` is `age < 18`,
and `nil..nil` matches every row. **Requires the next Ruflet release** (on `main`, not in 0.0.23).
With 0.0.23 such a range matches no rows; write the bound as a string instead:

```ruby
User.where("age >= ?", 18)
```

## Transactions

```ruby
User.transaction do
  user = User.create!(name: "Grace")
  user.posts.create!(title: "Compiler notes")
end
```

A transaction commits when the block returns and rolls back when it raises;
the exception is raised again. A transaction inside another one is a SQLite
savepoint, so rescuing an error inside the outer block rolls back only the
inner one. `RufletRecord.connection.transaction` works the same way.

With 0.0.23, leave a transaction block only by reaching its end or by raising.
A `return`, `break` or `throw` out of the block leaves the transaction open:
every later write joins it, other connections cannot write, and all of it
is rolled back when the connection closes. Return from the method after the
block instead.

A `return`, `break` or `throw` out of the block commits, as in Active Record,
and a thread killed inside the block rolls back. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## SQL and errors

For uncommon SQL, use the connection directly. `execute(sql, binds)` returns
the rows as hashes with string keys:

```ruby
RufletRecord.connection.execute("SELECT COUNT(*) AS n FROM users WHERE active = ?", [true])
```

`true` and `false` are passed as 1 and 0, and a `Time` as
`YYYY-MM-DD HH:MM:SS`. A statement SQLite rejects raises
`RufletRecord::StatementInvalid`. RufletRecord's errors all inherit from
`RufletRecord::Error`: `ConnectionNotEstablished`, `StatementInvalid`,
`RecordNotFound`, `RecordInvalid`, `RecordNotSaved` and
`UnknownAttributeError`. Invalid arguments raise `ArgumentError`.

A `Time` bind is converted to UTC first. **Requires the next Ruflet release** (on `main`, not in 0.0.23).

## Use it in a Ruflet app

Open the database and define the schema when the app starts, then query from
event handlers:

```ruby
require "ruflet"
require "ruflet_record"

RufletRecord.establish_connection(database: File.join(__dir__, "notes.sqlite3"))

RufletRecord::Schema.define do
  create_table :notes, if_not_exists: true do |table|
    table.string :title, null: false
    table.timestamps
  end
end

class Note < RufletRecord::Base
  validates_presence_of :title
  scope :recent, -> { order(id: :desc).limit(20) }
end

Ruflet.run do |page|
  draft = ""
  rows = -> { Note.recent.map { |note| text(value: note.title) } }
  notes = column(children: rows.call)
  status = text(value: "")

  field = text_field(label: "New note", on_change: ->(event) { draft = event.data.to_s })
  save = filled_button(
    content: text(value: "Save"),
    on_click: ->(_event) {
      note = Note.new(title: draft.strip)
      if note.save
        page.update(notes, controls: rows.call)
        page.update(status, value: "Saved")
      else
        page.update(status, value: note.errors.full_messages.join(", "))
      end
    }
  )

  page.add(column(children: [row(children: [field, save]), status, notes]))
end
```

In a server-driven app the database lives with the Ruby server, so every
client sees the same rows.

### Self-contained builds

> **Requires the next Ruflet release** (on `main`, not in 0.0.23). The `ruby_runtime` published for 0.0.23 has no RufletRecord, so `require "ruflet_record"` fails in a `--self` build.

The embedded Ruby of a `--self` build has RufletRecord built in, with its own
SQLite, so `require "ruflet_record"` works there without the gem. The
database path must be one the app can write to on the device. The copy in the
embedded Ruby predates every change above that is marked for the next
release, so follow the 0.0.23 notes there: write an open bound as a string,
leave transaction blocks at their end, store UTC times and JSON strings, and
set `user_id` rather than `user`.

## Deliberate limits

RufletRecord is not Rails Active Record. It deliberately omits callbacks,
single-table inheritance, eager loading, polymorphic associations, other
databases than SQLite, and Arel. It keeps no record of applied migrations, and
it has only the presence and uniqueness validations. Hard invariants belong in
SQLite constraints and unique indexes.
