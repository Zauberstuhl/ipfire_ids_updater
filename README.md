IPFire IDS Updater
==================

Installation
------------

Clone the repository into your favourite directory:

    git clone git@github.com:/zauberstuhl/ipfire_ids_updater.git /path/to/repo/

Open crontab via command-line `fcrontab -e` and append to the end:

    5 6 * * * perl /path/to/repo/ids_updater.pl &

Or if you'd like to have a changelog on your web-interface:

    5 6 * * * perl /path/to/repo/ids_updater.pl > /srv/web/ipfire/html/ids_changelog.txt &

You can visit the changelog via `https://<YOURHOSTORIP>:444/ids_changelog.txt`!
