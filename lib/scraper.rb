require 'open-uri'
require 'nokogiri'
require 'pry'

class Scraper

  def self.scrape_index_page(index_url)
    html = File.read(index_url)
    students_xml_array = Nokogiri::HTML(html)
    all_students = []
    students_xml_array.css("div.student-card").each do |student|
      all_students << {
        :name => student.css("h4.student-name").text,
        :location => student.css("p.student-location").text,
        :profile_url => student.css("a").attribute("href").value }
    end
    all_students
  end

  def self.icon_url(social)
    social.children.css("img").attribute("src").value
  end

  def self.create_bio_from(socials)
    bio_info = {}
    socials.each do |social|
      social_url = social.attribute("href").value
        if self.icon_url(social).include?("twitter")
          bio_info[:twitter] = social_url
        elsif self.icon_url(social).include?("linkedin")
          bio_info[:linkedin] = social_url
        elsif self.icon_url(social).include?("github")
          bio_info[:github] = social_url
        elsif self.icon_url(social).include?("rss")
          bio_info[:blog] = social_url
        end
      end
      bio_info
  end

  def self.scrape_profile_page(profile_url)
    html = File.read(profile_url)
    student_profile = Nokogiri::HTML(html)
    socials = student_profile.css("div.social-icon-container a")
    bio = self.create_bio_from(socials)
    bio[:profile_quote] = student_profile.css("div.profile-quote").text
    bio[:bio] = student_profile.css("div.description-holder p").text
    bio
  end
end
