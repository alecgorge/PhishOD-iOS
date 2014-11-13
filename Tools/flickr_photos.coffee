Flickr = require 'flickrapi'
async = require 'async'

info = [
      { "id": "15556579348", "owner": "38811370@N05", "secret": "1648db959a", "server": "7476", "farm": 8, "title": "Balcony View from a room at the Cosmopolitan", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15708683445", "owner": "38811370@N05", "secret": "f1c75e4031", "server": "7537", "farm": 8, "title": "Your Trip is Short... Las Vegas, Nevada", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15558476158", "owner": "82847947@N00", "secret": "5d97346927", "server": "7538", "farm": 8, "title": "Phish 10", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15745437392", "owner": "82847947@N00", "secret": "5f9b87406a", "server": "5616", "farm": 6, "title": "Phans", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15741991651", "owner": "82847947@N00", "secret": "b36dce1e7e", "server": "7523", "farm": 8, "title": "Page McConnell 2", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15558475408", "owner": "82847947@N00", "secret": "100e7a19e7", "server": "3940", "farm": 4, "title": "Phish 8", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15558736257", "owner": "82847947@N00", "secret": "a5f5a97d5b", "server": "3944", "farm": 4, "title": "Phish 9", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15743903085", "owner": "82847947@N00", "secret": "16e5364e87", "server": "7529", "farm": 8, "title": "Trey Anastasio 2", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15743902895", "owner": "82847947@N00", "secret": "6f4afc7727", "server": "7558", "farm": 8, "title": "Phish 7", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15720195126", "owner": "82847947@N00", "secret": "e0e5f5437c", "server": "3943", "farm": 4, "title": "Mike Gordon 2", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15720194586", "owner": "82847947@N00", "secret": "4265822c9c", "server": "3944", "farm": 4, "title": "Jon Fishman 2", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15745436132", "owner": "82847947@N00", "secret": "bde6c3b799", "server": "7528", "farm": 8, "title": "Phan", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15743902355", "owner": "82847947@N00", "secret": "630fa5950f", "server": "3944", "farm": 4, "title": "Phish 6", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15720194256", "owner": "82847947@N00", "secret": "ab8df33831", "server": "8406", "farm": 9, "title": "Phish 5", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15123955674", "owner": "82847947@N00", "secret": "18e2e88719", "server": "3946", "farm": 4, "title": "Phish 4", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15558734537", "owner": "82847947@N00", "secret": "237584036f", "server": "3942", "farm": 4, "title": "Phish 3", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15745435032", "owner": "82847947@N00", "secret": "566621301a", "server": "3941", "farm": 4, "title": "Phish 2", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15720193006", "owner": "82847947@N00", "secret": "edc06591b2", "server": "7462", "farm": 8, "title": "Page McConnell 1", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15558733547", "owner": "82847947@N00", "secret": "128da36ff9", "server": "7485", "farm": 8, "title": "Trey Anastasio 1", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15741989271", "owner": "82847947@N00", "secret": "c916eef583", "server": "7502", "farm": 8, "title": "Mike Gordon 1", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15743901215", "owner": "82847947@N00", "secret": "649e0ce1f5", "server": "5615", "farm": 6, "title": "Jon Fishman 1", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15745434042", "owner": "82847947@N00", "secret": "30d2a56fc3", "server": "7551", "farm": 8, "title": "Phish 1", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15559077530", "owner": "82847947@N00", "secret": "cf98a663f8", "server": "3954", "farm": 4, "title": "Bill Graham Civic Auditorium marquee", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15028014153", "owner": "17573696@N00", "secret": "8956b37643", "server": "7556", "farm": 8, "title": "Phish at The Forum 10\/24\/2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15410890370", "owner": "17573696@N00", "secret": "d9fd63bbda", "server": "5612", "farm": 6, "title": "Santa Barbara Bowl Rooftop Terrace Panorama", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14640615378", "owner": "7830943@N03", "secret": "86bf704747", "server": "3889", "farm": 4, "title": "Phish", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14640706797", "owner": "7830943@N03", "secret": "d3556680d3", "server": "2913", "farm": 3, "title": "Phish", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14826888192", "owner": "7830943@N03", "secret": "7354723f52", "server": "3850", "farm": 4, "title": "Shakedown", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14576655630", "owner": "126377022@N07", "secret": "b5bdb4cf26", "server": "3908", "farm": 4, "title": "Image from page 35 of \"Price list of art brass goods : hat racks, umbrella stands, tables ...\" (1886)", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14755854601", "owner": "126377022@N07", "secret": "64f30bfc84", "server": "3871", "farm": 4, "title": "Image from page 701 of \"The street railway review\" (1891)", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14871945135", "owner": "20456447@N03", "secret": "9f7c9a14ff", "server": "3925", "farm": 4, "title": "Phish 7.13.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14848944626", "owner": "20456447@N03", "secret": "d0c9b7ff18", "server": "5580", "farm": 6, "title": "Phish 7.13.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14869460584", "owner": "20456447@N03", "secret": "686fc0cbf4", "server": "5560", "farm": 6, "title": "Phish 7.13.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14685373107", "owner": "20456447@N03", "secret": "925c6956f8", "server": "3872", "farm": 4, "title": "Phish 7.13.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14868663454", "owner": "20456447@N03", "secret": "7004f77133", "server": "5555", "farm": 6, "title": "Phish 7.13.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14868652684", "owner": "20456447@N03", "secret": "4ff55dd563", "server": "3883", "farm": 4, "title": "Phish 7.13.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14870695272", "owner": "20456447@N03", "secret": "67c45c1870", "server": "5552", "farm": 6, "title": "Phish 7.12.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14890918123", "owner": "20456447@N03", "secret": "eef81e4538", "server": "5559", "farm": 6, "title": "Phish 7.12.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14868551544", "owner": "20456447@N03", "secret": "0ea9e42f4d", "server": "3916", "farm": 4, "title": "Phish 7.12.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14684356489", "owner": "20456447@N03", "secret": "91cbd83429", "server": "3905", "farm": 4, "title": "Phish 7.12.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14684454297", "owner": "20456447@N03", "secret": "bf340d58d6", "server": "3837", "farm": 4, "title": "Pi in the Sky", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14684268340", "owner": "20456447@N03", "secret": "80f75c591b", "server": "3847", "farm": 4, "title": "Phish 7.12.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14684440387", "owner": "20456447@N03", "secret": "c8e91f7beb", "server": "3875", "farm": 4, "title": "Phish 7.12.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14684293369", "owner": "20456447@N03", "secret": "cc2ea8201d", "server": "3905", "farm": 4, "title": "Phish 7.12.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14867840391", "owner": "20456447@N03", "secret": "f12282fda1", "server": "3884", "farm": 4, "title": "Saturday in the Park, I think it was the 12th of July", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14684121040", "owner": "20456447@N03", "secret": "dacd036bd6", "server": "3919", "farm": 4, "title": "Huge Crowd Walking Off Randall's Island", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14684146399", "owner": "20456447@N03", "secret": "2241e5a3bb", "server": "3853", "farm": 4, "title": "Phish 7.11.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14847784476", "owner": "20456447@N03", "secret": "90d6a369de", "server": "5577", "farm": 6, "title": "Phish 7.11.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14847768976", "owner": "20456447@N03", "secret": "7f36517556", "server": "5562", "farm": 6, "title": "Phish 7.11.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14446115318", "owner": "20456447@N03", "secret": "b782e707cd", "server": "3873", "farm": 4, "title": "Phish 7.11.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14890589593", "owner": "20456447@N03", "secret": "ecb00cdb4f", "server": "5590", "farm": 6, "title": "Phish 7.11.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14684103029", "owner": "20456447@N03", "secret": "566bb18a14", "server": "3867", "farm": 4, "title": "Phish 7.11.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14890565293", "owner": "20456447@N03", "secret": "27a4c07b2e", "server": "3867", "farm": 4, "title": "Phish 7.11.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14868192634", "owner": "20456447@N03", "secret": "12c240acbf", "server": "3915", "farm": 4, "title": "Welcome To Our Joy", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14896779821", "owner": "49287570@N06", "secret": "7f8d3fc2a0", "server": "5582", "farm": 6, "title": "IMG_4943", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14713158340", "owner": "49287570@N06", "secret": "9829174c25", "server": "3886", "farm": 4, "title": "IMG_4941", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14713295587", "owner": "49287570@N06", "secret": "65f20efb57", "server": "3917", "farm": 4, "title": "IMG_4939", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14876837416", "owner": "49287570@N06", "secret": "86eef747b8", "server": "5557", "farm": 6, "title": "IMG_4940", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14899826925", "owner": "49287570@N06", "secret": "2e8c5f7468", "server": "5573", "farm": 6, "title": "IMG_4938", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14899827335", "owner": "49287570@N06", "secret": "62c3afc209", "server": "5591", "farm": 6, "title": "IMG_4937", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14896782351", "owner": "49287570@N06", "secret": "c0e29a8d87", "server": "5596", "farm": 6, "title": "IMG_4936", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15035531213", "owner": "44124462151@N01", "secret": "fa54b76947", "server": "7581", "farm": 8, "title": "Phish", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15298814571", "owner": "27303150@N05", "secret": "61c197d670", "server": "3884", "farm": 4, "title": "Yeah, knock off the friggin' hacky sack. This isn't a Phish show. #RiotFest", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14591401880", "owner": "126377022@N07", "secret": "5d8031b3d1", "server": "5563", "farm": 6, "title": "Image from page 55 of \"Mouldings, mirrors, pictures and frames.\" (1884)", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14777763612", "owner": "126377022@N07", "secret": "4b355c7eae", "server": "2916", "farm": 3, "title": "Image from page 55 of \"Mouldings, mirrors, pictures and frames.\" (1884)", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14576718928", "owner": "126377022@N07", "secret": "c098ebe304", "server": "5587", "farm": 6, "title": "Image from page 34 of \"Price list of art brass goods : hat racks, umbrella stands, tables ...\" (1886)", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14778905193", "owner": "126377022@N07", "secret": "2f52e13af2", "server": "5578", "farm": 6, "title": "Image from page 701 of \"The street railway review\" (1891)", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14682668986", "owner": "33909090@N00", "secret": "9e5778a609", "server": "2928", "farm": 3, "title": "#phish #chicago #nightthree", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14509699388", "owner": "33909090@N00", "secret": "a3345f5922", "server": "5594", "farm": 6, "title": "#phish #chicago #nighttwo", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14880842949", "owner": "62281335@N07", "secret": "e2520ac66a", "server": "3905", "farm": 4, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15067178382", "owner": "62281335@N07", "secret": "e2e8d4a7f9", "server": "3852", "farm": 4, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15044539586", "owner": "62281335@N07", "secret": "10e4ab91e1", "server": "3898", "farm": 4, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15064517451", "owner": "62281335@N07", "secret": "32887d7cb3", "server": "3865", "farm": 4, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15044538406", "owner": "62281335@N07", "secret": "5d0ed5792c", "server": "3912", "farm": 4, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14880893790", "owner": "62281335@N07", "secret": "f7be9fef56", "server": "3864", "farm": 4, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15067178122", "owner": "62281335@N07", "secret": "455db7a661", "server": "5589", "farm": 6, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14880894570", "owner": "62281335@N07", "secret": "a513abc7cd", "server": "3866", "farm": 4, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15044538806", "owner": "62281335@N07", "secret": "26f9327165", "server": "5577", "farm": 6, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14880987297", "owner": "62281335@N07", "secret": "f9200cf9ff", "server": "3911", "farm": 4, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14880957358", "owner": "62281335@N07", "secret": "aeb2f0f4ed", "server": "3839", "farm": 4, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15044539096", "owner": "62281335@N07", "secret": "1b1921bd44", "server": "3923", "farm": 4, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15064517131", "owner": "62281335@N07", "secret": "5fb10f578b", "server": "3844", "farm": 4, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15067180642", "owner": "62281335@N07", "secret": "83e1b1e712", "server": "3878", "farm": 4, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15067180912", "owner": "62281335@N07", "secret": "aeefc710b8", "server": "3876", "farm": 4, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14880896640", "owner": "62281335@N07", "secret": "16de691e04", "server": "3892", "farm": 4, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14880896170", "owner": "62281335@N07", "secret": "b134931d1b", "server": "5554", "farm": 6, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15067546155", "owner": "62281335@N07", "secret": "3180ee3d50", "server": "5578", "farm": 6, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15067543705", "owner": "62281335@N07", "secret": "6f08cb2a3d", "server": "3872", "farm": 4, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15064518961", "owner": "62281335@N07", "secret": "4e1c5d13b6", "server": "5554", "farm": 6, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "15064519071", "owner": "62281335@N07", "secret": "06eee63564", "server": "3904", "farm": 4, "title": "FuzZz - 19 July 2014", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14501983528", "owner": "33909090@N00", "secret": "471e78301c", "server": "5577", "farm": 6, "title": "#phish #chicago #nightone #fatkidfuckparty", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14665598046", "owner": "33909090@N00", "secret": "63377fba0a", "server": "5567", "farm": 6, "title": "#phish #chicago #nightone", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14502329327", "owner": "33909090@N00", "secret": "16466ffec5", "server": "3880", "farm": 4, "title": "#phish #chicago #nightonee", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14648240235", "owner": "20963604@N08", "secret": "1bb8661743", "server": "3873", "farm": 4, "title": "Phish. Randall's Island. New York City. 7.11.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14643463052", "owner": "20963604@N08", "secret": "9deb83788e", "server": "3909", "farm": 4, "title": "Phish. Randall's Island. New York City. 7.12.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14457252749", "owner": "20963604@N08", "secret": "89c33e36fe", "server": "3853", "farm": 4, "title": "Phish. Randall's Island. New York City. 7.12.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14607829136", "owner": "20963604@N08", "secret": "974d49c34f", "server": "3850", "farm": 4, "title": "Phish. Randall's Island. NYC. 7.11.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14628005624", "owner": "20963604@N08", "secret": "6eef46cc44", "server": "5499", "farm": 6, "title": "Tonight's plan. Phish. Randall's Island. NYC. 7.11.14", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14611455991", "owner": "73256646@N00", "secret": "bf4ebf9493", "server": "2921", "farm": 3, "title": "Best spot in the lot. #phish #mannup", "ispublic": 1, "isfriend": 0, "isfamily": 0 },
      { "id": "14632472733", "owner": "73256646@N00", "secret": "1fc6f1a1b7", "server": "2923", "farm": 3, "title": "Before Tuesday's storm arrived. #phish #mannup #latergram", "ispublic": 1, "isfriend": 0, "isfamily": 0 }
    ];

users = { '37364931@N06': 'erocsid',  '82847947@N00': 'michaelz1',  '17573696@N00': 'andysternberg',  '94745953@N04': 'Trevor Bexon',  '7830943@N03': 'Shan213',  '33909090@N00': 'eytonz',  '45021273@N08': 'Laurel L. Russwurm',  '49287570@N06': 'Nate Merrill',  '39918526@N04': 'eventphotosnyc' }

# ids = urls.map (v) -> v.substr(36,11)
# infos = ids.map((v) ->
# 	for i in info
# 		if i.id is v
# 			return i

# 	console.log v
# ).filter (v) -> v isnt undefined

user_ids = info.map((v) ->	v.owner).filter (v, i, s) -> v and s.indexOf(v) is i

###
Flickr.tokenOnly {api_key: '104693e3d59adf9799f94ff0fb50ee58', secret: '399c603968610057'}, (err, flickr) ->
	throw err if err

	async.each user_ids, (u, cb) ->
		flickr.people.getInfo {user_id: u}, (err, result) ->
			return cb(err) if err

			users[u] = result.person.username._content

			cb()
	, (err) ->
		throw err if err

		console.log users
###

j = info.map (v, i) ->
	return {
		title: v.title
		owner: users[v.owner]
		url: "https://farm#{v.farm}.staticflickr.com/#{v.server}/#{v.id}_#{v.secret}_b.jpg"
	}

console.log JSON.stringify(j)
# console.log info.length, j.length
