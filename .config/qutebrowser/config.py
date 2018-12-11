config.set("auto_save.session", True)
#config.set("url.default_page", "https://www.google.it")
#config.set("url.start_pages", ["https://www.google.it"])

config.set("content.headers.referer", "always")
config.set("content.headers.custom", {
  "Masturbates-To-Anime-Girls": "yes",
  "Some-Body-Once-Told-Me": "The-World-Is-Gonna-Roll-Me",
  "I-Aint": "The-Sharpest-Tool-In-The-Shed",
})

config.aliases = {
  "animu": "https://myanimelist.net/anime/season",
  "todo": "localhost",
}

config.set("url.searchengines", {
  "DEFAULT": "https://duckduckgo.com/?q={}",
  "g": "https://www.google.it/search?q={}",
  "4": "https://boards.4chan.org/{}",
  "8": "https://8ch.net/{}",
  "r": "https://www.reddit.com/r/{}",
  "t": "https://twitter.com/{}",
  "y": "https://www.youtube.com/results?search_query={}",
  "f": "https://www.facebook.com/{}",
  "gh": "https://github.com/{}",
  "nyaa": "https://nyaa.si/?f=0&c=0_0&q={}",
  "fap": "https://sukebei.nyaa.si/?f=0&c=0_0&q={}",
  "mal": "https://myanimelist.net/search/all?q={}",
  "ex": "https://exhentai.org/?f_doujinshi=1&f_manga=1&f_artistcg=1&f_gamecg=1&f_western=0&f_non-h=1&f_imageset=1&f_cosplay=0&f_asianporn=0&f_misc=1&f_search={}&f_apply=Apply+Filter",
  "exh": "https://exhentai.org/?f_doujinshi=1&f_manga=1&f_artistcg=1&f_gamecg=1&f_western=0&f_non-h=1&f_imageset=1&f_cosplay=0&f_asianporn=0&f_misc=1&f_search={}&f_apply=Apply+Filter",
  "eh": "https://g.e-hentai.org/?f_doujinshi=1&f_manga=1&f_artistcg=1&f_gamecg=1&f_western=0&f_non-h=1&f_imageset=1&f_cosplay=0&f_asianporn=0&f_misc=1&f_search={}&f_apply=Apply+Filter",
})

config.set("content.host_blocking.whitelist", [ 'kiwifarms.net' ])

config.bind("<Ctrl-m>", "spawn utl-open {url}")
