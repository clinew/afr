# Low-energy makefile.
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

default:
	true

install:
	cp afr /usr/local/bin/afr
	cp afrc /usr/local/bin/afrc
	cp afr_lib.sh /usr/local/bin/afr_lib.sh
	mkdir -p /etc/afr
ifeq (,$(wildcard /etc/afr/openssl.cnf))
	cp openssl.cnf /etc/afr/openssl.cnf
endif
ifeq (,$(wildcard /etc/afr/afr.conf))
	cp afr.conf /etc/afr/afr.conf
endif
