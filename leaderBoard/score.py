from google.appengine.ext import ndb
import logging

class Score(ndb.Model):
	nickname = ndb.StringProperty()
	level = ndb.IntegerProperty(default=0)
	score = ndb.IntegerProperty(default=0)
