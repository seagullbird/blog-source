---
title: "How to Deploy a Flask App to Heroku"
date: 2016-11-27T10:20:05+08:00
draft: false
tags: ["Python", "Flask", "Heroku"]
---

The deploy tutorial on \<Flask Web Development> has somehow been out-dated. Follow this blog and you will know the differences.

<!--more-->

## Sign up for Heroku

Visit [Heroku](http://heroku.com/) website and create your own heroku account. Try not to forget your password immediately.

## Install Heroku Toolbelt

[Download Heroku toolbelt](https://toolbelt.heroku.com/) and install it as guided.

## Login

After installing heroku toolbelt properly, open your terminal.

```
$ heroku login
Enter your Heroku credentials.
Email: <your-email-address>
Password (typing will be hidden): <your-password>
Uploading ssh public key .../id_rsa.pub
```

Enter your email address and password, and you are logged in. Btw, the `login` command will automatically (create and) upload your SSH public key.

## Create an app

```
$ heroku create <appname>
Creating <appname>... done, stack is cedar
http://<appname>.herokuapp.com/ | git@heroku.com:<appname>.git
Git remote heroku added
```

There's little to talk about at this step. just try to think of a fascinating name for your own app, and it should always inlude only lower case letters. (Try not to and you'll get an error just as I did.)

Now you have a domain and a remote git repository. Will use them later.

## Config database

Now this is (seemingly?) the only different step from the tutorial in \<Flask Web Development>.

```
$ heroku addons:add heroku-postgresql:hobby-dev
Creating heroku-postgresql:hobby-dev on ⬢ <appname>... free
Database has been created and is available
 ! This database is empty. If upgrading, you can transfer
 ! data from another database with pg:copy
Created postgresql-lively-71535 as DATABASE_URL
Use heroku addons:docs heroku-postgresql to view documentation
```

Now the environment variable `DATABASE_URL` has saved the URL for the database. And this is the end of configuring database :)

## Set environment variables

Now you may tell me there are a few things you don't want to put in your codes cause they are so important. So let's save them in Heroku's environment. And this is the usual format:

```
$ heroku config:set <ENV-VAR-NAME>=<value>
```

As for me I set:

```
$ heroku config:set <appname>_CONFIG=heroku
Setting <appname>_CONFIG and restarting ⬢ <appname>... done, v4
<appname>_CONFIG: heroku
$ heroku config:set MAIL_USERNAME=<mymailusername>
Setting MAIL_USERNAME and restarting ⬢ <appname>... done, v5
MAIL_USERNAME: <mymailusername>
heroku config:set MAIL_PASSWORD=<mymailpassword>
Setting MAIL_PASSWORD and restarting ⬢ <appname>... done, v6
MAIL_PASSWORD: <mymailpassword>
```

## Run produce environment web server

Hekoru doesn't provide a produce server, so we have to supply our own.

```
(venv) $ pip install gunicorn
```

## Add requirements.txt

Just put all the requirements in your project's root in a file named `requirements.txt`.

## Add Procfile

Another file to add, at root, named `Procfile`, containing:

```
web: gunicorn manage:app
```

That's it.

------

Now there's one more part which I'm not gonna talk about in this blog since it depends on your code:

- Use Flask-SSLify to initial safe HTTP

Please try to work through this (or read chapter *17.4.3* in \<Flask Web Development>) before continuing.

------

## Implement your deploy

```
$ git push heroku master
```

```
$ heroku run python manage.py deploy
```

Where `deploy` is a command declared in `manage.py` aiming to upgrade database.

**./manage.py:**

```python
# ...
@manager.command
def deploy():
    """Run deployment tasks."""
    from flask_migrate import upgrade

    # migrate database to latest revision
    upgrade()
# ...
```

```
$ heroku restart
```

And you're ready to go!
