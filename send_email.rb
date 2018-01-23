require'pry'
require 'google_drive'
require 'gmail'
require_relative 'email_mairies.rb'  #appel du fichier qui créé un hash
require_relative 'get_html.rb'  #appel de mon email rédigé en html


 #fonction pour creer un spreadsheet Google Drive pour y mettre un Hash
 #creation d'un spreadsheet dont on donne le titre en attirbut de la fonction
def send_to_gdrive(this_hash, my_title)
  session = GoogleDrive::Session.from_config("config.json")
  spreadsheet = session.create_spreadsheet(title = my_title)

 #ws est la première page du sheet du hash
 #premiere colonne, premiere ligne = "VILLE" 
 #deuxieme colonne, premiere ligne = "EMAIL"
    ws = spreadsheet.worksheets[0]
  		ws[1, 1] = "ville"
		ws[1, 2] = "Email"
		ws.save

 #variable i = 2 car le contenu du hash commence a la deuxieme ligne
 #iteration sur hash
 #key correspond a chaque ligne de la premiere colonne
 #value correspond a chaque ligne de la deuxieme colonne
 #incrementation du i pour passé à la ligne suivante
	i = 2 
	this_hash.each do |key, value|
		ws[i, 1] = key
		ws[i, 2] = value
		ws.save 
		i +=1
	end
 #on retourne le spreadsheet rempli pour l'utiliser avec d'autres fonctions
  return ws
end

 #fonction qui envoie l'email avec deux attributs, email = destination et ville = nommer la ville
 #ligne 43: mettre son username et password
 #my_html(ville) est une fonction sur le fichier get_html qui contient le texte html
def send_email(ville, email)

	gmail = Gmail.connect("username", "password") do |gmail|
		gmail.deliver do 
			  to email
			  subject "The Hacking Project à #{ville} - formation au code gratuite !"
			  html_part do
			    content_type 'text/html; charset=UTF-8'
			    body my_html(ville)
		  	  end
	    end
	end
end
 #fonction pour orchestrer les autres : elle crée un spreadsheet à partir d'un hash, puis parcour toutes les lignes pour envoyer des emails
 #appel à la fonction send_to_gdrive pour créer un spreadsheet sur Google Drive
 #iteration pour parcourir toutes les lignes du spreadsheet et envoyer des emails
 #ws[i, 1] = colonne VILLES et ws[i, 1] = colonne EMAIL (lors du scrap des emails, un espace subsiste devant, la commande [1..100] l'enleve)
def wrap_up(this_hash, my_title)
	session = GoogleDrive::Session.from_config("config.json")
	ws = send_to_gdrive(this_hash, my_title)
	for i in (2..ws.num_rows) do 
		  send_email(ws[i, 1], ws[i, 2][1..100]) 
	end
end

 #appel du hash issu du programme de scrapping dans le fichier ruby townhall
 #on appelle notre fonction avec deux attributs, notre hash et le titre du spreadsheet qu'on veut créer
my_hash = get_all_the_urls_of_yonne_townhalls 
wrap_up(my_hash, "email_mairies_V2")