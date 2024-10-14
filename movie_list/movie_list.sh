#!/bin/bash

ml_start_backend() {
	sudo docker start mongo-3.4
	cd ~/non-work/movie-list/backend
	npm run dev
}


ml_start_fronted() {
	cd ~/non-work/movie-list/frontend
	npm run dev
}

ml_code() {
	code ~/non-work/movie-list/
}

ml_connect() {
	 docker exec -it mongo-3.4 mongo mongodb://admin:mypass@localhost/moviedb?authSource=admin
}

ml_download() {
	cd non-work/movie-list/tmdb-script/
	npm start
}
