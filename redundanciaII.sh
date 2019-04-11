#!/bin/bash
# Observacoes
#
# Esse script prove de forma simples e eficiente uma redundancia entre
# dois links de internet (sem load balance), sendo um link principal e o outro de backup.
#
# Crie o arquivo com o nome que quiser, no nosso caso como redundancia.sh
# Torne-o um executavel com o comando chmod +x redundancia.sh
# Adicione a linha abaixo no crontab   crontab -e
# * * * * *   /etc/script/redundancia.sh

# Gateway ativo
# Esse comando vefirica qual o link esta como padrao, se o link tiver como padrao o GW1
# ele vai pingar no ip externo e se responde e porque o link esta normal e nao faz mais nada
export LC_ALL=C
export PATH=/bin:/usr/bin:/sbin:/usr/sbin

GWUP=`ip route show | grep ^default | cut -d " " -f 3`
LOGS=/var/log/redundancia.log
# Gateway Principal
GW1=192.168.0.1; export GW1 # Substitua pelo gateway do seu link principal

# Gateway Slave
GW2=172.32.0.1; export GW2 # Substitua pelo gateway do seu link backup

# Etapa 1 = Verifica se o gateway e o principal, ser for ele vai pra etapa 2 se nao for ele vai pra etapa 2.1
if [ $GWUP == $GW1 ]; then

# Etapa 2 = Informa com log que a rota principal e o gateway 1 e vai para a etapa 6
   echo "`date` - Rota default é a Principal!  192.168.0.1" >> $LOGS

else

# Etapa 2.1 = Informa com log que a rota principal e o gateway 2 e vai para a etapa 3
   echo "`date` - Rota default é a Slave!  Gateway 172.32.0.1" >> $LOGS

# Etapa 3 = Verifica a disponibilidade do link com gateway 1
   echo "`date` - Verificando a disponibilidade do link principal..." >> $LOGS
   route add -net 0.0.0.0 gw $GW1
   ping -I eno1 8.8.8.8 -c 5 -A > /dev/null
   if [ $? -eq 0 ]; then

# Epata 4 = Se o gateway principal voltou ele exclui a rota do gateway 2 para manter o gatewy 1 ativo
      echo "`date` - Link pricipal voltou!" >> $LOGS
      route del -net 0.0.0.0 gw $GW2
      exit 0

   else
# Etapa 5 = Agora se o gatewy principal nao voltou, ele deleta a rota o gatewy 1 e mantem a rota do gateway 2
      echo "`date` - Link principal ainda nao voltou..." >>$LOGS
      echo "`date` - Link de backup sera mantido." >> $LOGS
      route del -net 0.0.0.0 gw $GW1
      exit 0

   fi

fi

# Etapa 6 = Testando se o link principal com gateway 1 esta normal, se tiver ele vai pra etapa 7
echo "`date` - Testando Link Principal..." >> /$LOGS
ping -I eno1 8.8.8.8 -c 5 -A > /dev/null

if [ $? -eq 0 ]; then

# Etapa 7 = Diz que o link principal com gateway 1 esta normal e finaliza
   echo "`date` - Link Principal UP!" >> $LOGS

else
# Etapa 8 = Diz que o link principal nao esta funcionado e deleta a rota do gateway um e adiciona rota ao gateway 2
   echo "`date` - Link Principal DOWN..." >> $LOGS
   echo "`date` - Subindo Link de backup..." >> /var$LOGS
   route del -net 0.0.0.0 gw $GW1
   ip route add default via $GW2

fi
