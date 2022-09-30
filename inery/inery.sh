#!/bin/bash
clear
merah="\e[31m"
kuning="\e[33m"
hijau="\e[32m"
biru="\e[34m"
UL="\e[4m"
bold="\e[1m"
italic="\e[3m"
reset="\e[m"
# logo
curl -s https://raw.githubusercontent.com/jambulmerah/guide-testnet/main/script/logo.sh | bash
sleep 2
trap
# Set account
echo -e "$bold$hijau 1. Set account... $reset"
sleep 1
# Set account name
accname="Enter your account name: "
while true; do
echo "======================================================================="
read -p "$(printf "$biru""$bold""$accname""$reset")" name
echo "======================================================================="
    if [[ -z $name ]]; then
        echo -e ""$bold"Input can't be blank, please try again\n"
        accname="Please enter your account name: "
    else
	while true; do
        echo -e -n "Is this account name $bold$hijau"$name"$reset correct? [Y/n]"
        read yn
        case $yn in
            [Yy]* ) printf "\n"; ACC=true; break;;
            [Nn]* ) printf "\n"; ACC=false; break;;
            * ) echo -e ""$bold"Invalid input. Please select yes or no\n"$reset"";;
        esac
        done
        if [[ $ACC = true ]]; then
            break
        fi
            if [[ $ACC = false ]]; then
	        accname="Enter your account name again: "
                continue
            fi
    fi
done

# Set pubkey
publickey="Enter your public-key: "
while true; do
echo "======================================================================="
read -p "$(printf "$biru""$bold""$publickey""$reset")" pubkey
echo "======================================================================="
    if [[ -z $pubkey ]]; then
        echo -e ""$bold"Input can't be blank, please try again\n"
        publickey="Please enter your public-key: "
    else
	while true; do
        echo -e -n "Is this public-key $bold$hijau"$pubkey"$reset correct? [Y/n]"
        read yn
        case $yn in
            [Yy]* ) printf "\n"; PUB=true; break;;
            [Nn]* ) printf "\n"; PUB=false; break;;
            * ) echo -e ""$bold"Invalid input. Please select yes or no\n"$reset"";;
        esac
        done
        if [[ $PUB = true ]]; then
            break
        fi
            if [[ $PUB = false ]]; then
	        publickey="Enter your public-key again: "
                continue
            fi
    fi
done

# Set privkey
privatekey="Enter your private-key: "
while true; do
echo "======================================================================="
read -p "$(printf "$biru""$bold""$privatekey""$reset")" privkey
echo "======================================================================="
    if [[ -z $privkey ]]; then
        echo -e ""$bold"Input can't be blank, please try again\n"
        privatekey="Please enter your private-key: "
    else
	while true; do
        echo -e -n "Is this private-key $bold$hijau"$privkey"$reset correct? [Y/n]"
        read yn
        case $yn in
            [Yy]* ) printf "\n"; PRIV=true; break;;
            [Nn]* ) printf "\n"; PRIV=false; break;;
            * ) echo -e ""$bold"Invalid input. Please select yes or no\n"$reset"";;
        esac
        done
        if [[ $PRIV = true ]]; then
            break
        fi
            if [[ $PRIV = false ]]; then
	        privatekey="Enter your private-key again: "
                continue
            fi
    fi
done
echo "======================================================================="
echo -e "Your account name is: $bold$hijau$name$reset"
echo -e "Your pub-key is: $bold$hijau$pubkey$reset"
echo -e "Your priv-key is: $bold$hijau$privkey$reset"
echo "======================================================================="
echo
sleep 2

# Update upgrade
echo -e "$bold$hijau 2. Updating packages... $reset"
sleep 1
sudo apt update && sudo apt upgrade -y

# Install dep
echo -e "$bold$hijau 3. Installing dependencies... $reset"
sleep 1
sudo apt install -y make bzip2 automake libbz2-dev libssl-dev doxygen graphviz libgmp3-dev \
autotools-dev libicu-dev python2.7 python2.7-dev python3 python3-dev \
autoconf libtool curl zlib1g-dev sudo ruby libusb-1.0-0-dev \
libcurl4-gnutls-dev pkg-config patch llvm-7-dev clang-7 vim-common jq libncurses5 ccze

echo -e "$bold$hijau 4. Installing node... $reset"
sleep 1
# Clone repo
cd $HOME
rm -rf inery-node
git clone https://github.com/inery-blockchain/inery-node

# Edit permission and set vars
echo -e "export PATH="$PATH":"$HOME"/inery-node/inery/bin:"$HOME"/inery-node/inery.setup/master.node" >> $HOME/.bash_profile
echo -e "export IneryAccname="$name"" >> $HOME/.bash_profile
echo -e "export IneryPubkey="$pubkey"" >> $HOME/.bash_profile
echo -e "export inerylog="$HOME"/inery-node/inery.setup/master.node/blockchain/nodine.log" >> $HOME/.bash_profile
source $HOME/.bash_profile
sudo source $HOME/.bash_profile

# Set config
peers="$(curl -s ifconfig.me):9010"
sed -i "s/accountName/$name/g;s/publicKey/$pubkey/g;s/privateKey/$privkey/g;s/IP:9010/$peers/g" $HOME/inery-node/inery.setup/tools/config.json

echo -e "$bold$hijau 5. Running master node... $reset"
sleep 1
chmod 777 $HOME/inery-node/inery.setup/ine.py
sudo tee $HOME/temporary > /dev/null <<EOF
#!/bin/bash
cd $HOME/inery-node/inery.setup/
./ine.py --master \\
>> tempo.log 2>&1 & \\
echo $! > tempo.pid
EOF
bash $HOME/temporary
killall temporary
rm -rf $HOME/temporary
sudo kill $(cat $HOME/inery-node/inery.setup/tempo.pid)
rm -rf $HOME/inery-node/inery.setup/tempo*
cd; cline wallet create -n $name --file $name.txt
cline wallet unlock -n $name --password $(cat $name.txt)
cline wallet import -n $name --private-key $privkey

# Enable firewall
sudo ufw allow 8888,9010/tcp
sudo ufw allow ssh
sudo ufw limit ssh
sudo ufw enable

echo -e "\n========================$bold$biru SETUP FINISHED$reset ============================"
echo -e "Source vars environment:$bold$hijau source \$HOME/.bash_profile $reset"
echo -e "Check your account name env vars:$bold$hijau echo $IneryAccname $reset"
echo -e "Check your public-key env vars:$bold$hijau echo $IneryPubkey $reset"
echo -e "Check logs with command:$bold$hijau tail -f \$inerylog | ccze -A $reset"
echo -e "========================$bold$biru SETUP FINISHED$reset ============================\n"
