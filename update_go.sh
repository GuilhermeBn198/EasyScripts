#!/usr/bin/env bash

# Verificar a versão atual usando 'go version'
version=$(go version 2>/dev/null || echo "none")
release=$(wget -qO- "https://golang.org/VERSION?m=text" | awk '/^go/{print $0}')

if [[ $version == *"$release"* ]]; then
    echo "The local Go version ${release} is up-to-date."
    exit 0
else
    echo "The local Go version is ${version}. A new release ${release} is available."
fi

release_file="${release}.linux-amd64.tar.gz"

# Criar diretório temporário
tmp=$(mktemp -d)
cd $tmp || exit 1

echo "Downloading https://go.dev/dl/$release_file ..."
curl -OL https://go.dev/dl/$release_file

# Remover a instalação anterior de Go e extrair a nova versão
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf $release_file

# Limpar arquivos temporários
rm -rf $tmp

# Voltar para o diretório home para evitar erros de 'getwd'
cd ~

# Definir o GOROOT corretamente (caso não esteja configurado)
export GOROOT=/usr/local/go
export PATH=$GOROOT/bin:$PATH

# Verificar se a nova versão do Go foi instalada corretamente
version=$(go version)
if [[ $version == *"$release"* ]]; then
    echo "Now, local Go version is $version"
else
    echo "Failed to update Go. Current version is still $version."
    exit 1
fi
