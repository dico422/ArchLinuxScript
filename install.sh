#!/bin/bash

main(){

    basic

    fdisk-prog

    format-disc

    mount-disc

    pacman-basic

    genstab -U /mnt >> /mnt/etc/fstab

    archchroot

    config

    umount /dev/sda2

}

config(){

    COUNTRY="Brazil"
    ZONE="East"
    ln -sf /usr/share/zoneinfo/${COUNTRY}/${ZONE} /etc/localtime

    hwclock --systohc

    LANG="pt_BR"

    sed -i "s/#${LANG}/${LANG}/g" /etc/locale.gen

    KEYMAP="lat1_16.psfu"

    echo "KEYMAP=${KEYMAP}" >> /etc/vconsole.conf

    MYHOSTNAME="Armando"

    echo "${MYHOSTNAME}" >> /etc/hostname

    IP="127.0.0.1"

    echo "${IP} \t\t localhost" >> /etc/hosts
    echo "::1 \t\t localhost" >> /etc/hosts
    echo "${IP} \t\t ${MYHOSTNAME}.localdomain ${MYHOSTNAME}" >> /etc/hosts

}


pacman-basic(){

    pacman -Sy
    pacstrap /mnt base linux linux-firmware

}

basic(){

    # Primeiro escolheremos o layout do teclado
    loadkeys us # podemos mudar `us` para `br-abnt2`

    # Em seguida definimos uma fonte para o console
    setfont lat1-16.psfu # nesta opcao, o Ç é incluso, assim como as acentuacoes

    # Garantimos que o relogio esteja correto
    timedatectl set-ntp true

    # Limparemos qualquer reparticao que o disco tiver
    wipefs -a /dev/sda

}

mount-disc(){

    swapon /dev/sda1

    # Montaremos o disco em /mnt
    mount /dev/sda2 /mnt

}

format-disc(){

    # Formataremos o disco em mkfs.ext4
    mkfs.ext4 /dev/sda2

    # Formatearemos o SWAP
    mkswap /dev/sda1

}

# Utilizaremos o programa `fdisk` para reparticionar os discos

# Criaremos primeiro a Swap e em seguida a principal
# Com os seguintes argumentos
# n -> nova particao
# p -> primaria
# em seguida o numero da particao
# e por fim os setores inicial e final

# o comando `a` permite que voce escolha a particao que sera bootavel ( na qual sera a 1 )
# e em seguida mudaremos o tipo `t` da particao 2 para SWAP(82)
# e por fim escreveremos `w`
fdisk-prog(){

# Limparemos qualquer reparticao que o disco tiver
wipefs -a /dev/sda

# Sector, Size, ID, Bootable (*,-)
sfdisk /dev/sda << EOF
,2G,82
,,83,*
EOF

}

archchroot(){

    cp ${0} /mnt/root
    chmod 755 /mnt/root/$(basename "${0}")
    arch-chroot /mnt /root/$(basename "${0}") --chroot ${1} ${2}
    rm /mnt/root/$(basename "${0}")

}


main