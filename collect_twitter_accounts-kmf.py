import psycopg2
import tweepy
import logging
import time


# Go to http://dev.twitter.com and create an app.
# The consumer key and secret will be generated for you after
consumer_key = '2Qv9qMeJBQW8LoSqESwxekwZL'
consumer_token = 'dEPjkRJPOXFnkL8nMsRkdiDGTY9WPNNmUBPRQF4QEdNeWLRC3B'

# After the step above, you will be redirected to your app's page.
# Create an access token under the the "Your access token" section
access_token = '1759131-t8BgZvRHKrjEa4iBXdi6sg6TKpMmFni1BQjKUbMelq'
access_token_secret = 'XlErRy3L2nJ8X1EWPIvIApMgzaUgRhozFfNmfItBROM92'

# consumer_key = '6WqCLElvMLYiQDnaLtcRMNm5Z'
# consumer_token= 'Fh1firIXdBtRCIAYe7ojNjAhkqfP3LYmCzEgixUu2Pu4eyY9Wr'
# access_token ='17298291-DoYnEMgJ91RIUFzhfguTeLp53GdiKk9qt162RVSrm'
# access_token_secret = 'RLFWzMvbtfhnh8M72ozMxyNLCgFOcrMCJP7IU31T7ka1M'

# from secrets import consumer_key, consumer_secret, access_token, access_token_secret

auth = tweepy.OAuthHandler(consumer_key, consumer_token)
auth.set_access_token(access_token, access_token_secret)

logging.basicConfig(filename='counties.log',  level = logging.INFO, format='%(asctime)s %(levelname)-8s %(message)s')



api = tweepy.API(auth)
# API has a 15 minute call interval
interval = 900
rate_limit = 180
def main():
	conn = psycopg2.connect('dbname=twitter_feeds user = postgres password=password')
	cur = conn.cursor()
	county_query ='select distinct(county) from counties;'
	_t = cur.execute(county_query)
	# county = counties.fetchone()
	calls = 0
	county = cur.fetchone()[0]
	while county:
		#search for county results in twitter.
		print(county)
		start_time = time.time()
		print(str(calls) + "calls made")
		if calls == (rate_limit - 1):
			print('450 call limit reached. Sleeping')
			tts = interval - (time.time() - start_time)
			print('Sleeping for ' + str(tts) + " seconds")
			time.sleep(interval - (time.time() - start_time))

		cursor = get_search_results(county)
		calls +=1
		count = 0
		for page in cursor:
			if count >= 100:
				break
			for user in page:
				screen_name = user.screen_name
				name = user.name
				uid = user.id_str
				location = user.location
				if location != "":
					count +=1
					print('Name: ' + name + ' UID: ' + uid + " Screen Name: " + screen_name + ' Location: ' + location)
		print(str(count))
		county = cur.fetchone()[0]
				

def get_search_results(query):
	cursor = tweepy.Cursor(api.search_users,q =query).pages(10)
	return cursor

def query_db(query):
	_t = db.query(query)
	results =db.use_results()
	return
def insert_feed(uid, screen_name, lang, page_state, verified_county, search_county):

    query = '''INSERT IGNORE INTO twitter_feeds (uid, name, page_state, verified_county, search_county, user_name) VALUES("%s","%s","%s","%s","%s","%s")''' % (uid, name, page_state, verified_county, search_county, screen_name)
    logging.debug("Query: " + query)
    r = db.query(query)
    logging.debug("Query results: " + r)
if __name__ == "__main__":
	main()
