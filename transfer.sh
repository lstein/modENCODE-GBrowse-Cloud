rsync -Ravvz --copy-links -e'ssh -o "StrictHostKeyChecking no" -i /home/lstein/temporary_key -p12345 -lubuntu' ./browser_data localhost:/modencode/
