# Public API

## Browse

[`https://www.livephish.com/api.aspx/?method=catalog.containerCategories`](https://www.livephish.com/api.aspx/?method=catalog.containerCategories)

## Browse > SUMMER TOUR 2014

[`http://www.livephish.com/api.aspx?method=catalog.containerCategories.containers&containerCategoryID=57`](http://www.livephish.com/api.aspx?method=catalog.containerCategories.containers&containerCategoryID=57)

## Browse > SUMMER TOUR 2014 > 7/1/2014

[`https://www.livephish.com/api.aspx/?method=catalog.container&containerID=847`](https://www.livephish.com/api.aspx/?method=catalog.container&containerID=847)

# Private API

Before every private API call, you must first use the authentication API call to get a token to use on the subsequent API call. This expire rather quickly so don't try to reuse them.

## Authentication

### Request
[`https://www.livephish.com/secureApi.aspx?method=session.getUserToken&clientID=Trfgyskdjfnm234jfj3342&developerKey=dhsuwncuej432ldkf943kf3&user=[EMAIL]&pw=[PASSWORD]`](https://www.livephish.com/secureApi.aspx?method=session.getUserToken&clientID=Trfgyskdjfnm234jfj3342&developerKey=dhsuwncuej432ldkf943kf3&user=[EMAIL]&pw=[PASSWORD])

### Response

```
{
	"methodName": "session.getUserToken",
	"Response": {
		"tokenValue": "51 character token",
		"returnCode": 1,
		"returnCodeStr": "VALID",
		"nnCustomerAuth": {
			"email": "[EMAIL]",
			"credentialValidationStr": "USER_PW_OK_NO_CHECKSUM",
			"credentialValidation": 2
		}
	},
	"responseAvailabilityCode": 0,
	"responseAvailabilityCodeStr": "AVAILABLE",
	"sessionState": 1,
	"sessionStateStr": "VALID"
}
```

## Stash

### Request
[`https://www.livephish.com/secureApi.aspx?method=user.stash&developerKey=dhsuwncuej432ldkf943kf3&token=[TOKEN]&user=[EMAIL]`](https://www.livephish.com/secureApi.aspx?method=user.stash&developerKey=dhsuwncuej432ldkf943kf3&token=[TOKEN]&user=[EMAIL])

### Response

See `stash.json`.

## Single Show

### Request
[`https://www.livephish.com/secureApi.aspx?method=user.catalog.container&developerKey=dhsuwncuej432ldkf943kf3&user=[EMAIL]&token=[TOKEN]&containerID=494`](https://www.livephish.com/secureApi.aspx?method=user.catalog.container&developerKey=dhsuwncuej432ldkf943kf3&user=[EMAIL]&token=[TOKEN]&containerID=494)

### Response

See `show.json`.

## Stream track

### Request
[`https://www.livephish.com/secureApi.aspx?method=user.player&developerKey=dhsuwncuej432ldkf943kf3&user=[EMAIL]&token=[TOKEN]&trackID=6972&passID=2099272&skuID=7246`](https://www.livephish.com/secureApi.aspx?method=user.player&developerKey=dhsuwncuej432ldkf943kf3&user=[EMAIL]&token=[TOKEN]&trackID=6972&passID=2099272&skuID=7246)

### Response

```
{
  "methodName": "user.player",
  "Response": {
    "ttl": 0,
    "ip": "[IP]",
    "songTitle": null,
    "mb": 0,
    "hash": null,
    "skuFound": true,
    "email": "[EMAIL]",
    "developerKey": "dhsuwncuej432ldkf943kf3",
    "hasAccess": true,
    "skuID": 7246,
    "trackID": 6972,
    "orderID": 2099272,
    "urlToSign": null,
    "fileInfo": {
      "codecDesc": null,
      "fileID": 9891,
      "showID": 411
    },
    "url": "http://www.livephish.com/bigriver/bigriver.aspx?oi=2099272&mediaid=7246&file=9891&show=411&codec=&ge=1406247071&dk=dhsuwncuej432ldkf943kf3&sig=[32 char key]"
  },
  "responseAvailabilityCode": 0,
  "responseAvailabilityCodeStr": "AVAILABLE",
  "sessionState": 1,
  "sessionStateStr": "VALID"
}
```

`Response.url` will redirect to an MP3
.