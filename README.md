# Apiban Clients

**APIBAN is made possible by the generosity of our [sponsors](https://apiban.org/doc.html#sponsors).**

Sample clients have been provided in a simple bash script or golang (go). The basic concept would be to create a chain in IPTABLES called APIBAN and have the clients executed via `crontab`.

**The [GO client](https://github.com/apiban/apiban-client-go) has been tested more than the bash script**. It is recommended that the bash only be used as a template.

The [GO client](https://github.com/apiban/apiban-client-go) is provided as both source code to build and an executable suitable for most nix environments. It assumes that it will be run in `/usr/local/bin/apiban/`.

_**UPDATES 2020-09-01**_

* added nftables client for bash (tested on debian 9/10)

## Client - bash

Use the GO client if you can... the bash script is suitable for a template. **Not recommended for production.**

Bash script to check apiban API and block returned IP addresses with **iptables**.

### How to use

1. Download apiban.sh and apibanconfig.sys
2. Make sure `jq` is installed on your system (`apt install jq`)
3. Replace `MYAPIKEY` in apibanconfig.sys with your apiban api key
4. Run `chmod +x apiban.sh`
5. Run `./apiban.sh` as needed (cron recommended)

## How it works

The client pulls the API key and last known ID from the **apibanconfig.sys** file.

When the script is executed, it first checks to see if the **APIBAN** chain exists in iptables. If the chain does not exist, it is recreated and the **LKID** is reset (allowing a full dump).

IP addresses are added to APIBAN chain and actions are logged in **apiban-client.log**.

## Warranty

This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
