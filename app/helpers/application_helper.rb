module ApplicationHelper
  def flash_class(type)
    case type.to_s
    when "notice"
      "bg-green-900 border border-green-700 text-green-100"
    when "alert"
      "bg-red-900 border border-red-700 text-red-100"
    when "error"
      "bg-red-900 border border-red-700 text-red-100"
    else
      "bg-gray-900 border border-gray-700 text-gray-100"
    end
  end
end
