publish:
	@-rm -r public
	hugo
	rsync -rlv --delete public/ fredcy.com:/var/www/fredcy
