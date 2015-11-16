module ApplicationHelper
  def full_title(page_title='')
    base_title = 'Ach So!'
    if page_title.empty?
      base_title
    else
      page_title + ' | ' + base_title
    end
  end
  def sss
    SSS
  end
end
