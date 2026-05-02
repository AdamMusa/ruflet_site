# frozen_string_literal: true

module RufletStudio
  module SectionsControls
    DIGITS = %w[0 1 2 3 4 5 6 7 8 9].freeze

    def build_calculator(page, status)
      display = calculator_display(page)
      container(
        width: 420,
        padding: 12,
        border_radius: 12,
        bgcolor: color_panel(page),
        content: column(
          spacing: 12,
          children: [
            status,
            container(height: 24),
            row(alignment: "end", children: [display]),
            container(height: 20),
            calculator_keypad_row(page, display, status, "BS", "AC", "%", "/"),
            calculator_keypad_row(page, display, status, "7", "8", "9", "x"),
            calculator_keypad_row(page, display, status, "4", "5", "6", "-"),
            calculator_keypad_row(page, display, status, "1", "2", "3", "+"),
            calculator_keypad_row(page, display, status, "+/-", "0", ".", "=")
          ]
        )
      )
    end

    def calculator_state(page)
      page.instance_variable_get(:@calculator_state) ||
        page.instance_variable_set(:@calculator_state, { display: "0", operand: nil, operator: nil, start_new_value: false })
    end

    def calculator_display(page)
      text(
        value: calculator_state(page)[:display],
        text_align: "right",
        style: { size: 84, color: color_text(page) }
      )
    end

    def calculator_keypad_row(page, display, status, *labels)
      row(
        alignment: "center",
        spacing: 6,
        children: labels.map do |label|
          elevated_button(
            content: text(value: label),
            width: 78,
            height: 65,
            color: calculator_key_text_color(page, label),
            bgcolor: calculator_key_bg(page, label),
            on_click: ->(e) { calculator_handle_input(label, e, page, display, status) }
          )
        end
      )
    end

    def calculator_key_bg(page, label)
      %w[/ x - + =].include?(label) ? color_accent(page) : color_surface(page)
    end

    def calculator_key_text_color(page, label)
      %w[/ x - + =].include?(label) ? "#FFFFFF" : color_text(page)
    end

    def calculator_handle_input(label, event, page, display, status)
      if DIGITS.include?(label)
        calculator_on_digit(page, label)
      elsif label == "."
        calculator_on_decimal(page)
      elsif %w[x / - +].include?(label)
        calculator_on_operator(page, label)
      elsif label == "="
        calculator_on_equals(page)
      elsif label == "AC"
        calculator_reset(page)
      elsif label == "+/-"
        calculator_on_toggle_sign(page)
      elsif label == "%"
        calculator_on_percent(page)
      elsif label == "BS"
        calculator_on_backspace(page)
      end

      page.update(display, value: calculator_state(page)[:display])
      page.update(status, value: "Calculator result: #{calculator_state(page)[:display]}") if label == "="
      event
    end

    def calculator_on_digit(page, digit)
      state = calculator_state(page)
      if state[:start_new_value] || state[:display] == "Error"
        state[:display] = digit
        state[:start_new_value] = false
        return
      end

      state[:display] = (state[:display] == "0" ? digit : "#{state[:display]}#{digit}")
    end

    def calculator_on_decimal(page)
      state = calculator_state(page)
      if state[:start_new_value] || state[:display] == "Error"
        state[:display] = "0."
        state[:start_new_value] = false
        return
      end

      state[:display] += "." unless state[:display].include?(".")
    end

    def calculator_on_operator(page, next_operator)
      state = calculator_state(page)
      if state[:operator] && !state[:start_new_value]
        calculator_apply_calculation(page)
        return if state[:display] == "Error"
      else
        state[:operand] = calculator_to_number(state[:display])
      end

      state[:operator] = next_operator
      state[:start_new_value] = true
    end

    def calculator_on_equals(page)
      state = calculator_state(page)
      return unless state[:operator]

      calculator_apply_calculation(page)
      state[:operator] = nil if state[:display] != "Error"
    end

    def calculator_on_toggle_sign(page)
      state = calculator_state(page)
      return if state[:display] == "0" || state[:display] == "Error"

      state[:display] = if state[:display].start_with?("-")
                           state[:display][1..]
                         else
                           "-#{state[:display]}"
                         end
    end

    def calculator_on_percent(page)
      state = calculator_state(page)
      return if state[:display] == "Error"

      state[:display] = calculator_format_number(calculator_to_number(state[:display]) / 100.0)
      state[:start_new_value] = true
    end

    def calculator_on_backspace(page)
      state = calculator_state(page)
      return if state[:display] == "Error"

      if state[:display].length <= 1 || (state[:display].length == 2 && state[:display].start_with?("-"))
        state[:display] = "0"
        return
      end

      state[:display] = state[:display][0...-1]
    end

    def calculator_apply_calculation(page)
      state = calculator_state(page)
      right = calculator_to_number(state[:display])
      result = case state[:operator]
               when "+"
                 state[:operand] + right
               when "-"
                 state[:operand] - right
               when "x"
                 state[:operand] * right
               when "/"
                 return calculator_show_error(page) if right.zero?

                 state[:operand] / right
               end

      state[:display] = calculator_format_number(result)
      state[:operand] = calculator_to_number(state[:display])
      state[:start_new_value] = true
    end

    def calculator_to_number(value)
      Float(value)
    rescue StandardError
      0.0
    end

    def calculator_format_number(value)
      number = value.to_f
      return number.to_i.to_s if number == number.to_i

      number.to_s.sub(/\.?0+\z/, "")
    end

    def calculator_show_error(page)
      state = calculator_state(page)
      state[:display] = "Error"
      state[:operator] = nil
      state[:operand] = nil
      state[:start_new_value] = true
    end

    def calculator_reset(page)
      state = calculator_state(page)
      state[:display] = "0"
      state[:operand] = nil
      state[:operator] = nil
      state[:start_new_value] = false
    end
  end
end
