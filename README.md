# Redundancia_Entre_Dois_Links_Scipts
Observacões:
Esse script promove uma forma simples e eficiente uma redundancia entre  dois links de internet (sem load balance), sendo um link principal e o outro de backup.  
Cria um arquivo com o nome que quiser, no nosso caso como redundancia.sh  Torne-o um executável com o comando chmod +x redundancia.sh  Adicione a linha abaixo no crontab   crontab -e  * * * * *   /etc/script/redundancia.sh
Gateway ativo  Esse comando verifica qual o link esta como padrão, se o link tiver como padrão o GW1  ele vai pingar no ip externo e se responde e porque o link esta normal e não faz mais nada
