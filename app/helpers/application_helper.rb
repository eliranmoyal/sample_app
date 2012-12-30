module ApplicationHelper
  
  #return a title 
  def title
    base_title = "Ruby Sample App"
    if @title.nil?
      base_title
    else 
      "#{base_title} | #{@title}"
    end
  end

  def logo
  	image_tag("logo.png" , :alt => "Sample App" , :class => "round")
  end
    
end
