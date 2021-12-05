#!/bin/bash
####################################################################
#  Автор Ринат Фахрутдинов .  ptah57@mail.ru  2021
#
#  делаем из текстового вывода команды сканирования активных адресов nmap html табличку
#
#  $1 - первый параметр имя каталога (название дороги) откуда будет взят исходный файл, например MSK 
#  $1 - второй параметр имя копируемого файла с сервера , где было запущено сканирование адресов, например MTS
#  $3 - третий параметр имя каталога на сервере с MRTG куда будет скопирован результирующий html файл с таблицей, например msk
# 
#  $1 { MSK,OKT,SEV,SVK 
#  $2 {MTS,MEGAFON,TELE2,BEELINE 
#  $3 {msk,okt,sev.svk
# 
####################################################################
# Вначале проверяется правильность вызова процедуры с параметрами
# затем копируется с дорожного сервера текстовый файл с результатами сканирования
# затем генерится html таблица и копируется на сервер с MRTG данными
#
####################################################################
# все работы делаем в домашнем каталоге Нагиоса
#
####################################################################
DIR=/home/nagios

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]

then
        echo "Отсутствуют параметры при вызове скрипта. Например, для Московской дороги для получения таблицы активных клиентов МТС нужно так написать : ./`basename $0` MSK MTS msk "
        exit 3
else

  INDIR=$1
  INFILE=$2
  OUTDIR=$3

#
####################################################################
#   сначала скопируем результат сканирования с дорожного сервера
####################################################################

if [[ "$INDIR" = "MSK" && "$INFILE" = "MTS" ]]
then
echo " ...копируется файл $DIR/$INDIR/$INFILE ...."
/usr/bin/scp 10.200.1.30:/root/MM /home/nagios/MSK/MTS  2>/dev/null && /bin/sleep 5 
fi

if [[ "$INDIR" = "MSK" && "$INFILE" = "MEGAFON" ]]
then
echo " ...копируется файл $DIR/$INDIR/$INFILE ...."
/usr/bin/scp 10.200.1.30:/root/MEGAF /home/nagios/MSK/MEGAFON  2>/dev/null && /bin/sleep 5
fi

count=`/bin/grep for $DIR/$INDIR/$INFILE | /usr/bin/wc -l` && /bin/sleep 5

if [[ "$INDIR" = "MSK" && "$INFILE" = "BEELINE" ]]
then
echo " ...копируется файл $DIR/$INDIR/$INFILE ...."
/usr/bin/scp 10.200.1.31:/root/BEELINE /home/nagios/MSK/BEELINE  2>/dev/null && /bin/sleep 5
#/usr/bin/snmpwalk -v 2c -c 0Ghbxybr 10.200.1.2 iso.3.6.1.2.1.4.21.1.1.10 | /bin/grep 10.1.2 | /usr/bin/cut -d " " -f 4 > $DIR/$INDIR/$INFILE && /bin/sleep 5 && 
count=`/bin/grep for $DIR/$INDIR/$INFILE | /bin/grep -v down | /usr/bin/wc -l` && /bin/sleep 5
echo $counter
fi


echo $counter

####################################################################
#  генерируем табличку для вебки 
####################################################################

if [[ "$INDIR" = "MSK" && "$INFILE" = "BEELINE" ]]
then

[ -f "$DIR/$INDIR/$INFILE" ] && /bin/grep for $DIR/$INDIR/$INFILE | /bin/grep -v down | /usr/bin/cut -d " " -f 5 | /usr/bin/awk -v counter="$count" -v x="$INDIR $INFILE"  'BEGIN { print " <h4> Список из  " counter "   активных концентраторов " x " на связи </h4> <br> <table> "} {  print "<tr> <td> " $1  " </td></tr>" } END { print "</table> " } ' > $DIR/body.html

else

[ -f "$DIR/$INDIR/$INFILE" ] && /bin/grep for $DIR/$INDIR/$INFILE | /usr/bin/cut -d " " -f 5 | /usr/bin/awk -v counter="$count" -v x="$INDIR $INFILE"  'BEGIN { print " <h4> Список из  " counter "   активных концентраторов " x " на связи </h4> <br> <table> "} {  print "<tr> <td> " $1  " </td></tr>" } END { print "</table> " } ' > $DIR/body.html

fi

cat $DIR/head.html $DIR/body.html $DIR/konec.html > $DIR/$INDIR/$INFILE.html 

####################################################################
#  затем копируем получившийся файл на сервер с mrtg
####################################################################

[ -f "$DIR/$INDIR/$INFILE.html" ] && /usr/bin/scp $DIR/$INDIR/$INFILE.html 10.200.18.31:/var/www/mrtg/$OUTDIR/$INFILE-activeIP.html

fi

#####################################################################
