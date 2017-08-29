import webapp2
import json
from score import *

class MainPage(webapp2.RequestHandler):
    
    ## Handling Http get request
    def get(self, num):
        ## Specifying content type
        self.response.headers['Content-Type'] = 'text/plain'
        ## Specifying content
        query = Score.query().order(-Score.score)
        scores = query.fetch()
        highScoreList = []

        for score in scores:
        	dict = {}
        	dict["score"] = score.score
        	dict["nickname"] = score.nickname
        	dict["level"] = score.level
        	if score.level == int(num):
        		highScoreList.append(dict)

        self.response.write(json.dumps(highScoreList[:4]))

class NewScoreHandler(webapp2.RequestHandler):
    def post(self, num):

    	nickname = self.request.get("nickname")
    	score = int(self.request.get("score"))

    	new_score = Score(nickname = nickname, level = int(num), score = score)
        new_score.put()
        self.response.write("posted")


## Specifies which path should be handled by which class
app = webapp2.WSGIApplication([
    webapp2.Route('/score/level/<num>', handler=MainPage),
    webapp2.Route('/new/level/<num>', handler=NewScoreHandler)
], debug=True)
