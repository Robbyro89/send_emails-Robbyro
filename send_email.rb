require'pry'
require 'google_drive'
require 'gmail'
require_relative 'townhalls.rb' #appel du fichier qui créé un hash
require_relative 'get_html.rb' #appel de mon email rédigé en html


 #fonction pour creer un spreadsheet Google Drive et y coller un Hash
 #création d'un spreadsheet dont on donne le titre en attirbut de la fonction
def go_to_gdrive(this_hash, my_title)
  session = GoogleDrive::Session.from_config("config.json")
  spreadsheet = session.create_spreadsheet(title = my_title) 
  
 #ws est la premiere page du sheet sur laquelle on va coller le hash
 #ligne 18: "VILLE" sur la premiere ligne, 1ere colonne
 #ligne 19: "EMAIL" sur la premiere ligne, 2eme colonne
  ws = spreadsheet.worksheets[0] 
  		ws[1, 1] = "VILLE" 
		ws[1, 2] = "EMAIL"
		ws.save

 #variable i initialisée a 2 pour que le contenu de notre hash soit colle a partir de la deuxieme ligne
 #ligne 25: itération du hash
 #key correspond a chaque ligne de la première colonne
 #value corresponda  chaque ligne de la deuxieme colonne
 #ligne 32: incrementation du i pour passer a la ligne d'apres a chaque tour de l'iteration
	i = 2 
	this_hash.each do |key, value| 
		ws[i, 1] = key 
		ws[i, 2] = value 
		ws.save 
		i +=1 
	end

  return ws #on retourne le spreadsheet (ws) pour pouvoir l'utiliser dans d'autres fonctions
end

 #fonction qui envoie l'email avec deux attributs, email pour la destination et ville pour pouvoir nommer la ville
 #ligne 42: mettre son username et son mdp
 #ligne 48: my_html(ville) est une fonction sur le fichier get_html qui contient mon texte html
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

 #fonction qui cree un spreadsheet a partir d'un hash, puis utilise toutes les lignes pour envoyer des emails
 #ligne 59: appel a la fonction ci-dessus pour creer un spreadsheet sur Google Drive
 #ligne 62: iteration pour parcourir toutes les lignes du spreadsheet et envoyer des emails
 #ws[i, 1] = colonne VILLES & ws[i, 1] = EMAIL (lors du scrap des emails, un espace subsiste devant, on peut appliquer la commande [1..100] pour l'enlever)
def wrap_up(this_hash, my_title) 
	session = GoogleDrive::Session.from_config("config.json")
	ws = go_to_gdrive(this_hash, my_title) 

	for i in (2..ws.num_rows) do 
		  send_email(ws[i, 1], ws[i, 2][1..100]) 
	end
end

 #appel du hash issu du programme de scrapping dans le fichier email_mairies.rb
 #on appelle la fonction avec deux attributs, le hash et le titre du spreadsheet a veut créer
my_hash = get_all_the_urls_of_val_doise_townhalls 
wrap_up(my_hash, "townhalls_final")