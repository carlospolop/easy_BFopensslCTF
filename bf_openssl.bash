#!/bin/bash

cyphers_aes_main="aes128 aes192 aes256 aes-128-cbc aes-192-cbc aes-256-cbc"
cyphers_aes_rest="aes-128-ecb aes-192-ecb aes-256-ecb"

cyphers_des_main="des des3 desx"
cyphers_des_rest="des-cbc des-cfb des-ecb des-ede des-ede-cbc des-ede-cfb des-ede-ofb des-ede3 des-ede3-cbc des-ede3-cfb des-ede3-ofb des-ofb"

cyphers_rc4_main="rc4"
cyphers_rc4_rest="rc4-40"

cyphers_rc2_main="rc2"
cyphers_rc2_rest="rc2-40-cbc rc2-64-cbc rc2-cbc rc2-cfb rc2-ecb rc2-ofb"

cyphers_bf_main="bf"
cyphers_bf_rest="bf-cbc bf-cfb bf-ecb bf-ofb"

cyphers_casts_main="cast"
cyphers_casts_rest="cast-cbc cast5-cbc cast5-cfb cast5-ecb cast5-ofb"

cyphers_seed_main="seed"
cyphers_seed_rest="seed-cbc seed-cfb seed-ecb seed-ofb"

cyphers_camellia_main="camellia128 camellia192 camellia256"
cyphers_camellia_rest="camellia-128-cbc camellia-128-cfb camellia-192-cbc camellia-192-cfb camellia-256-cbc camellia-256-cfb"

cyphers_id_rest="id-aes128-CCM id-aes128-GCM id-aes128-wrap id-aes192-CCM id-aes192-GCM id-aes192-wrap id-aes256-CCM id-aes256-GCM id-aes256-wrap"

total_cyphers="$cyphers_aes_main $cyphers_des_main $cyphers_rc4_main $cyphers_rc2_main $cyphers_bf_main $cyphers_casts_main $cyphers_seed_main $cyphers_camellia_main"

verbose=0
try_pass=false
password_file=false
b64=""
hlp_msg="$0 -f input_file [-v] [-a] [-b] [-h] [-t password] [-p pass_file]\n\tv: Verbose level\n\ta: All cyphers\n\tb: Base64\n\th: Help\n\tt: Use pass\n\tp: Use pass file"
while getopts f:vahbt:p: option
do
    case "${option}" in
        f) in_file=${OPTARG};; #Archivo para descifrar
        v) verbose=$(($verbose+1));; #Verbose activado
        a) total_cyphers+=" $cyphers_aes_rest $cyphers_des_rest $cyphers_rc4_rest $cyphers_rc2_rest $cyphers_bf_rest $cyphers_casts_rest $cyphers_seed_rest";; #Probamos todos los metodos de cifrado
        h) echo -e $hlp_msg; exit;; #Help
        b) b64="-a";; #File in B64 encoded
        t) try_pass=${OPTARG};; #Probamos una pass
        p) password_file=${OPTARG};; #Probamos una lista de passwords
    esac
done

#Check if input file setted
if [ -z ${in_file+x} ]; then 
    echo -e $hlp_msg
    exit
fi
#Check if input file exists
if [ ! -f $in_file ];then
    echo "Input file does not exist: $in_file"
    echo -e $hlp_msg
    exit
fi


function decode { #$1 password
    out_pref="dcd_"
    out_suf="_out"
    useless="data empty"
    important="[+]"

    echo "[i] Pass: $1"
    for cypher in $total_cyphers; do
        out="$out_pref$cypher$out_suf"
        openssl_line="openssl $cypher $b64 -d -in $in_file -out $out -pass pass:$1"
        output_openssl="$($openssl_line 2>&1)"
        next=false
        if [[ -f $out ]]; then #Comprobamos si existe el archivo descifrado
            output_file="$(file -z $out)"
            for i in $useless; do #Comprobamos si la salida del comando file tiene alguna palabra prohibida
                if [[ $output_file == *"$i"* ]]; then
                    next=true
                    if (( verbose > 0 ));then
                        echo $output_file
                        if (( verbose > 1 )); then #Si verbose 2 o más, mostramos la salida de openssl
                            echo $output_openssl
                        fi
                    fi
                fi
            done
            
            if [ "$next" = false ];then #Si no tenia ninguna de las palabras prohibidas
                echo "$important $output_file  ($openssl_line)"
            fi

            rm $out #Delete the file
        
        else #Si no existe el archivo de out
            if (( verbose > 0 ));then 
                echo "Error: no output file: $out"
            fi
        fi
    done
}

echo "Verbose: $verbose"
#Si se prueba 1 pass
if [ ! "$try_pass" = false ]; then
    decode $try_pass
    echo ""
fi

#Si se usa un archivo con passwords
if [ ! "$password_file" = false ]; then
    if [[ -f $password_file ]]; then
        while read line; do           
            decode $line
            echo ""     
        done <$password_file
    else
        echo "Password file does not exists: $password_file"
    fi
fi