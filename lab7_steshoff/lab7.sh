#!/bin/bash

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

printblockdevices() {
	df --output=source,fstype,target -x proc -x sys -x tmpfs -x devtmpfs | grep -v Filesystem
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

if [ "$EUID" -ne 0 ]; then
	echo "Не администратор"
	exit
fi

PS3='Please enter your choice: '
options=("Вывести таблицу файловых систем" "Монтировать файловую систему"\
 "Отмонтировать файловую систему" "Изменить параметры монтирования примонтированной файловой системы" \
 "Вывести параметры монтирования примонтированной файловой системы"\
 "Вывести детальную информацию о файловой системе ext*" \
 "Выйти"
)

select opt in "${options[@]}"
do
    case $opt in
	"Вывести таблицу файловых систем")
		printblockdevices
		;;
	"Монтировать файловую систему")
        read -p "Введите путь до файла/устройства: " filepath
		if [ "$filepath" == "" ]; then
			err "filepath cant be empty"
			continue 
		fi
	    if [ ! -b $filepath ] && [ ! -f $filepath ]; then
			err "not exist or not a blockdevice|file"
			continue
        fi
	    read -p "Введите каталог монтирования: " mountpath
		if [ "$mountpath" == "" ]; then
			err "mountpath cant be empty"
			continue
		fi 
	    if [ ! -e $mountpath ]; then
			mkdir -p $mountpath
	    elif [ -d $mountpath ]; then
			if [ ! -z "$(ls -A $mountpath)" ]; then
				err "directory not empty"
				continue
			fi
	    else
			err "Not a directory"
			continue
	    fi

	    if [ -f $filepath ]; then
            device=$(sudo losetup --find --show $filepath)
			mount $device $mountpath
	    else
			mount $filepath $mountpath
		fi
	    ;;
	"Отмонтировать файловую систему")
		read -p "Введите путь до файловой системы: " filesyspath
		if [ -z $filesyspath ]; then
			readarray -t mounts < <(printblockdevices)
			readinput mounts
			res=$?
			[ $res == 0 ] && continue
			filesyspath=$(echo ${mounts[res - 1]} | cut -d " " -f3 )
		fi
		umount $filesyspath
	    ;;

    "Изменить параметры монтирования примонтированной файловой системы")
	    read -p "Введите путь до файловой системы: " remountfilesyspath
		if [ -z $remountfilesyspath ]; then
			readarray -t mounts < <(printblockdevices)
			readinput mounts
			res=$?
			[ $res == 0 ] && continue
			remountfilesyspath=$(echo ${mounts[res - 1]} | cut -d " " -f3 )
		fi

	    chooseopt=("только чтение" "чтение и запись")
		readinput chooseopt
		res=$?
		if [ $res == 1 ]; then
	    	mount -o remount,ro $remountfilesyspath
	    else
            mount -o remount,rw $remountfilesyspath
		fi
        ;;

    "Вывести параметры монтирования примонтированной файловой системы")
	    read -p "Введите путь до файловой системы: " filesyspath #считать с консоли или дать выбрать
		if [ -z $filesyspath ]; then
			readarray -t mounts < <(printblockdevices)
			readinput mounts
			res=$?
			[ $res == 0 ] && continue
			filesyspath=$(echo ${mounts[res - 1]} | cut -d " " -f3 )
		fi
	    mount | grep $filesyspath
        ;;
 	"Вывести детальную информацию о файловой системе ext*")
	    readarray -t exts < <(df -t ext2 -t ext3 -t ext4 -t extcow --output=source,fstype,target 2>&1)
		arrsize=${#exts[@]}
	    if [ $arrsize == 1 ]; then
			echo "Нет файловых систем данного типа" 
		else 
			echo "Есть следующие системы:"
			readarray -t exts < <(df -t ext2 -t ext3 -t ext4 -t extcow --output=source,fstype,target | grep -v Filesystem )
			readinput exts
			res=$?
			[ $res == 0 ] && continue
			filesyspath=$(echo ${exts[res - 1]} | cut -d " " -f1 )
			tune2fs -l $filesyspath
		fi
        ;;
    "Выйти")
        break
        ;;
	*) echo "invalid option $REPLY";;
    esac
done
