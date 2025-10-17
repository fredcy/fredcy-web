publish:
	@-rm -r public
	hugo
	rsync -rlv --delete public/ repo.fredcy.com:/var/www/fredcy
