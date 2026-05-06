// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import { application } from "controllers/application"
import CopyCodeController from "controllers/copy_code_controller"

application.register("copy-code", CopyCodeController)
