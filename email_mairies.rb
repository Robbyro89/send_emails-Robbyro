require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require'pry'

 #fonction pour lancer la recherche d'un email si on a l'url de la mairie en question
 #[11] = position de l'email trouvee grace à l'inspecteur de console
def get_the_email_of_a_townhal_from_its_webpage(url_townhall) 
	url_townhall = Nokogiri::HTML(open(url_townhall))
	email_town = url_townhall.css("p.Style22")[11].text
	return email_town
end

 #methode pour recuperer toutes les adresse email des Mairies de l'Yonne
 #acceder aux nom des mairies et aux url pour accéder a leur page
 #ligne 37: [1..100] = itération sur chaque balise <a> pour isoler leur url (href) et enlever le point (.)
def get_all_the_url_of_yonne_townhalls
page = Nokogiri::HTML(open("http://www.annuaire-des-mairies.com/yonne.html"))
scrap = page.css("a.lientxt")
table = []
email_town = {}
	scrap.collect do |a|
		link = a['href'][1..100]
		page2 = "http://annuaire-des-mairies.com" + link
		email = get_the_email_of_a_townhal_from_its_webpage(new_page)
		ville = a.text
		email_town[ville] = email
	end
	return email_town
end