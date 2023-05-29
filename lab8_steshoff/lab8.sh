#!/bin/bash

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S')]: $*" >&2
}

readinput() {
	local -n arr=$1
	arr+=("Справка" "Назад")
	select opt in "${arr[@]}"; do
	case $opt in
		Назад) return 0;;
		Справка) echo "Введите число, соответствующее опции из списка";;
		*)
			if [[ -z $opt ]]; then
				echo "Ошибка: введите число из списка" >&2
			else
				return $REPLY
			fi
			;;
	esac
	done
}

unitpath() {
	tmp=$(systemctl status $1 | grep loaded | head -1)
	local path=$(awk '{ sub(/.*\(/, ""); sub(/;.*/, ""); print }' <<< $tmp)
	echo $path
}

if [ "$EUID" -ne 0 ]; then
	echo "Не администратор"
	exit
fi

PS3=$'\n> '
options=(
	"Поиск системных служб"
	"Вывести список процессов и связанных с ними systemd служб"
    "Управление службами"
	"Поиск событий в журнале"
	"Справка"
	"Выйти"
)

select opt in "${options[@]}"
do
	case $opt in
	"Поиск системных служб")
		read -p "Введите имя службы или его часть: " unit
        systemctl list-units --type=service | head -n -7 |  tail -n +2 | grep "$unit"
		;;

	"Вывести список процессов и связанных с ними systemd служб")
        ps ax -o'pid,unit' | grep  '\.service'
        ;;

	"Управление службами")
		readarray -t services < <(systemctl list-units --type=service | head -n -7 |  tail -n +2 | cut -d " " -f1)
		readinput services
		res=$?
		[ $res == 0 ] && continue
		service=${services[res - 1]}
		select opt in "Включить службу" "Отключить службу" "Запустить/перезапустить службу" "Остановить службу" "Вывести содержимое юнита службы" "Отредактировать юнит службы" "Справка" "Назад"; do
		case $opt in
            "Включить службу")
                systemctl enable "$service"
                ;;
            "Отключить службу")
                systemctl disable "$service"
                ;;
            "Запустить/перезапустить службу")
                systemctl restart "$service"
                ;;
            "Остановить службу")
                systemctl stop "$service"
                ;;
            "Вывести содержимое юнита службы")
                cat "$(unitpath $service)"
                ;;
            "Отредактировать юнит службы")
                nano "$(unitpath $service)"
                ;;
            "Справка")
                echo "Выберите опцию $service"
                ;;
            "Назад")
                break
                ;;
	        *) echo "Неправильная команда";;
		esac
		done
		;;
	"Поиск событий в журнале")
		read -p "Введите имя службы: " servicename  
		echo "Выберите степень важности: " 
		prioritylist=("emerg" "alert" "crit" "err" "warning" "notice" "info" "debug")
		readinput prioritylist
		res=$?
		[ $res == 0 ] && continue
		priority=${prioritylist[res - 1]}
		read -p "Введите строку поиска: " searchstring
		echo $priority
		if [$servicename == ""]; then 
			journalctl -p "$priority" -g "$searchstring"
		else 
			journalctl -p "$priority" -u "$servicename" -g "$searchstring"
		fi
		;;
	"Справка")
		echo "Введите интересующую команду"
		;;
	"Выйти")
		break
		;;
	*) echo "Неправильная команда";;
	esac
done