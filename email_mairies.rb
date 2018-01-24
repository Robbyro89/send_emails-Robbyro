require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require'pry'


#fonction pour lancer la recherche d'un email si on a l'url de la mairie en question
def get_the_email_of_a_townhal_from_its_webpage(url_townhall) 
	url_townhall = Nokogiri::HTML(open(url_townhall))
	email_town = url_townhall.css("p.Style22")[11].text #position de l'email trouvée grace a l'inspecteur
	return email_town
end

#fonction pour afficher toute les adresses email des mairies a partir de la page d'accueil
def get_all_the_urls_of_val_doise_townhalls
page = Nokogiri::HTML(open("https://annuaire-des-mairies.com/val-d-oise.html"))   

balise_a = page.css("a.lientxt") #commande pour acceder aux balises <a> qui contiennent le nom des mairies et l'url pour acceder a leur page

table = []
city_email = {}
		balise_a.collect do |a| 
			link = a['href'][1..100]  #iteration sur chaque balise <a> pour isoler leur url (href) et enlever le point (.)
			new_page = "https://annuaire-des-mairies.com" + link #reconstitution d'un url entier
			email = get_the_email_of_a_townhal_from_its_webpage(new_page) #appel a la fonction precedente grace a notre url
			ville = a.text
			city_email[ville] = email
			
        end
return city_email


end