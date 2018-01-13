---
title: "How to delete a Many-to-Many relationship in Flask-SQLAlchemy"
date: 2016-11-21T16:07:00+08:00
draft: false
tags: ["Python", "Flask", "Flask-SQLAlchemy"]
---

This used to be an unsolved issue; it is now solved, keeping records.

<!--more-->

Recently on writing my new project 'BLEXT' I met this problem. I was developing the blog re-editing feature, trying to make it possible to re-edit an existing blog while not creating a new blog (The last version will create a new blog under any circumstances  after `Publish` button is clicked). 

Since the user can re-edit anything about a blog including its tags and categories,  I will have to delete all previous relationships between this blog and its tags and categories and create new ones.

For categories this is easy job to do since category and blog have a One-to-Many relationship (a blog can only have one category while a category can have many blogs). All I have to do is `old_blog.category = new_category` and consider it done.

Now the problem is, while there is a Many-to-Many relationship between blogs and tags, and the models are defined like this:

```python
blog_tag = db.Table('blog_tag',
                    db.Column('tag_id', db.Integer, db.ForeignKey('tags.id')),
                    db.Column('page_id', db.Integer, db.ForeignKey('blogs.id'))
                    )


class Blog(db.Model):
    __tablename__ = 'blogs'
    # unrelavent properties
    tags = db.relationship('Tag', secondary=blog_tag,
                           backref=db.backref('blogs', lazy='dynamic'))
    # other unrelavent properties
        def __repr__(self):
        return '<Blog %r>' % self.title
    

class Tag(db.Model):
    __tablename__ = 'tags'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(20))
    # other unrelavent properties
    
    def __repr__(self):
        return '<Tag %r>' % self.name
```

Which is so well-defined as how the Flask-SQLAlchemy docs recommended. And normally (for example):

```python
>>> blog = Blog.query.first()
>>> blog.tags
[<Tag 'tag1_name'>, <Tag 'tag2_name'>, ...]
>>> tag = Tag.query.first()
>>> tag.blogs
[<Blog 'title1'>, <Blog 'title2'>, ...]
```

Just wanna say everything else works fine cause I did exatly what the docs recommended remember!?

And here comes the problem: I want to delete all of a blog's tags and append new ones to it. (Not talking about deleting any tags only the relationship). So I did this:

```python
# still the same blog instance as above
>>> blog.tags.clear()
>>> blog.tags
[]
>>> db.session.add(blog)
>>> db.session.commit()
```

'Tada!' I got this:

```python
Traceback (most recent call last):
  File "<console>", line 1, in <module>
  File "/Users/Seagullbird/Desktop/Codes/Python/Blext/venv/lib/python3.5/site-packages/sqlalchemy/orm/scoping.py", line 157, in do
    return getattr(self.registry(), name)(*args, **kwargs)
  File "/Users/Seagullbird/Desktop/Codes/Python/Blext/venv/lib/python3.5/site-packages/sqlalchemy/orm/session.py", line 874, in commit
    self.transaction.commit()
  File "/Users/Seagullbird/Desktop/Codes/Python/Blext/venv/lib/python3.5/site-packages/sqlalchemy/orm/session.py", line 461, in commit
    self._prepare_impl()
  File "/Users/Seagullbird/Desktop/Codes/Python/Blext/venv/lib/python3.5/site-packages/sqlalchemy/orm/session.py", line 441, in _prepare_impl
    self.session.flush()
  File "/Users/Seagullbird/Desktop/Codes/Python/Blext/venv/lib/python3.5/site-packages/sqlalchemy/orm/session.py", line 2136, in flush
    self._flush(objects)
  File "/Users/Seagullbird/Desktop/Codes/Python/Blext/venv/lib/python3.5/site-packages/sqlalchemy/orm/session.py", line 2254, in _flush
    transaction.rollback(_capture_exception=True)
  File "/Users/Seagullbird/Desktop/Codes/Python/Blext/venv/lib/python3.5/site-packages/sqlalchemy/util/langhelpers.py", line 60, in __exit__
    compat.reraise(exc_type, exc_value, exc_tb)
  File "/Users/Seagullbird/Desktop/Codes/Python/Blext/venv/lib/python3.5/site-packages/sqlalchemy/util/compat.py", line 186, in reraise
    raise value
  File "/Users/Seagullbird/Desktop/Codes/Python/Blext/venv/lib/python3.5/site-packages/sqlalchemy/orm/session.py", line 2218, in _flush
    flush_context.execute()
  File "/Users/Seagullbird/Desktop/Codes/Python/Blext/venv/lib/python3.5/site-packages/sqlalchemy/orm/unitofwork.py", line 386, in execute
    rec.execute(self)
  File "/Users/Seagullbird/Desktop/Codes/Python/Blext/venv/lib/python3.5/site-packages/sqlalchemy/orm/unitofwork.py", line 500, in execute
    self.dependency_processor.process_saves(uow, states)
  File "/Users/Seagullbird/Desktop/Codes/Python/Blext/venv/lib/python3.5/site-packages/sqlalchemy/orm/dependency.py", line 1092, in process_saves
    secondary_update, secondary_delete)
  File "/Users/Seagullbird/Desktop/Codes/Python/Blext/venv/lib/python3.5/site-packages/sqlalchemy/orm/dependency.py", line 1113, in _run_crud
    result.rowcount)
sqlalchemy.orm.exc.StaleDataError: DELETE statement on table 'blog_tag' expected to delete 4 row(s); Only 5 were matched.
```

If I do `blog.tags = []`   (instead of `blog.tags.clear()`), I got the same result on commiting `db`.

**Problem sovled:**

I used sqlite to directly examine the database and got as follows:

```sql
sqlite> .tables
alembic_version  blogs            tags
blog_tag         categories       users
sqlite> .schema blog_tag
CREATE TABLE blog_tag (
    tag_id INTEGER,
    page_id INTEGER,
    FOREIGN KEY(tag_id) REFERENCES tags (id),
    FOREIGN KEY(page_id) REFERENCES blogs (id)
);
sqlite> SELECT * FROM blog_tag;
1|2
1|2
2|2
4|2
3|2
```

And it's clear that my `blog_tag`  table is clearly messed up due to some previous operations. So I ran `delete from blog_tag;` and deleted everything in the table and did again the code above, nothing went wrong again. Since as the  code is well-established the tables won't be messed up again, I presume I'll never see this problem in this project any more.

Follows the right answer to the title of this blog: **How to delete a Many-to-Many relationship in Flask-SQLAlchemy:**

```python
>>> blog = Blog.query.first()
>>> blog.tags.clear()
>>> blog.tags
[]
>>> db.session.add(blog)
>>> db.session.commit()
```

Not any tags are deleted, just the relationships (aka. the records in `blog_tag` table) between this blog and its previous tags.



The End.
