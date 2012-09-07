-- nixio upnp search and NAT
-- http://upnp.org/resources/documents.asp
                -- for details about the UPnP message format, see http://upnp.org/resources/documents.asp
                payload = payload .. "M-SEARCH * HTTP/1.1\r\n"
                payload = payload .. "Host:239.255.255.250:1900\r\n"
                payload = payload .. "ST:upnp:rootdevice\r\n"
                payload = payload .. "Man:\"ssdp:discover\"\r\n"
                payload = payload .. "MX:3\r\n\r\n"
