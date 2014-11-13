
fs = require 'fs'

j = JSON.parse fs.readFileSync 'twitter_media.json'

imgs = j.map((v) ->
	if v.entities['media']
		return v.entities.media[0].media_url + ':large'
	else
		return undefined
).filter (v) -> v isnt undefined

j = imgs.map (v) ->
	return {
		title: "Photo by @Phish_FTR"
		owner: "Photo by @Phish_FTR"
		url: v
	}

console.log JSON.stringify(j)

