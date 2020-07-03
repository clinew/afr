#!/bin/bash

# Commands common to the AFR admin and client utilities.
#
# Copyright (C) 2020  Wade T. Cline
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Generate a CRL for the specified CA.
# 1: Directory name of the CA whose CRL will be generated.
ca_crl_gen() {
	pushd "$1"
	openssl ca -gencrl -config openssl.cnf -cert "certs/${1}.pem" -keyfile "private/${1}.pem" -out "crl/${1}.pem"
	popd
}

# Create a CA at the specified location.
# 1: Directory name for the CA.
ca_gen() {
	mkdir -p "$1"
	pushd "$1"
	cp "${openssl_cnf}" ./
	mkdir certs csr crl newcerts private
	touch index.txt
	echo 1000 > serial
	echo 1000 > crlnumber
	umask 0077
	openssl genrsa -out "private/$1.pem" 4096
	umask 0022
	popd
}

# Function to generate a CSR.
# 1: Directory name of the CA which will generate the CSR.
# 2: Common Name of the CA to request
ca_req_gen() {
	pushd "$1"
	openssl req -new -key "private/$1.pem" -out "csr/$1.pem" -subj "/CN=$2/"
	popd
}

# Function to retrieve a signed certificate from the signing CA back to the
# requesting CA.  This is currently a glorified wrapper for a copy function.
# $1 The CA which did the signing.
# $2 The CA which was signed.
ca_req_receive() {
	cp "$1/certs/$2.pem" "$2/certs/$2.pem"
}

# Function to sign a CSR from a CA.
# Signing a certificate and then immediately using it has been known to cause
# 'Not activated, or expired certificate' errors, so sign it 3 seconds in the
# past.
# 1: The CA which will sign.
# 2: The CA which will be signed.
# 3: Extensions section to use.
# 4 (optional): subjectAltName value.
# 5 (optional): Validity length in days.
ca_req_sign() {
	# Create additional extension.
	pushd "$1"
	if [ -n "$4" ]; then
		# Giant, fragile hack (see file).
		sed -i "s/FIXME_SAN/$4/" openssl.cnf
	fi
	if [ -n "$5" ]; then
		local days="-days $5"
	fi

	# Sign the certificate.
	openssl ca -config openssl.cnf -keyfile "private/${1}.pem" -cert "certs/${1}.pem" -extensions "$3" -in "csr/${2}.pem" -out "certs/${2}.pem" -batch ${days} -startdate $(TZ=UTC date +%Y%m%d%H%M%SZ --date "now - 3 seconds")
	popd
}

# Function to submit one CA's CSR to another CA for signing.  This is currently
# a glorified wrapper for a copy function.
# $1 The CA which will sign.
# $2 The CA which will be signed.
ca_req_submit() {
	cp "$2/csr/$2.pem" "$1/csr/$2.pem"
}

# Use the specified CA in order to revoke the specified certificate.  This
# will update the CRL for the specified CA.
# 1: Directory of the CA which will be issuing the revocation.
# 2: Name of the certificate which will be revoked.
ca_revoke() {
	pushd "$1"
	openssl ca -config openssl.cnf -keyfile "private/${1}.pem" -cert "certs/${1}.pem" -revoke "certs/${2}.pem"
	popd
	ca_crl_gen "${1}"
}

# Function to self-sign a CA.
# 1: Directory name of the CA to self-sign.
# 2: Common Name of the CA to self-sign.
ca_selfsign() {
	pushd "$1"
	openssl req -key "private/$1.pem" -days 36500 -new -x509 -out "certs/$1.pem" -subj "/CN=$2/"
	popd
}

# Print a message and exit the program with failure status.
# 1: The message to print
die() {
	echo "${1}"
	exit 1
}
