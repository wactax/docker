#!/usr/bin/env coffee

> fs > existsSync
  @w5/uridir
  path > dirname join
  dotenv > parse
  @w5/read
  @w5/write
  @w5/utf8/utf8e.js

ROOT = join(
  dirname dirname uridir import.meta
  'docker'
)

gen = (password,file)=>
  password = utf8e password.trim()
  HASH = (Buffer.from (await crypto.subtle.digest("SHA-256", password))).toString 'hex'

  PREFIX = "user default on sanitize-payload "
  USER = PREFIX+"##{HASH} ~* &* +@all"
  ACL = join ROOT,"data/redis#{file}/acl"

  li = []

  to_set = true

  if existsSync(ACL)
    acl = read(ACL).split('\n')
    for i from acl
      if to_set and i.startsWith(PREFIX)
        to_set = false
        li.push USER
      else if i
        li.push i

  if to_set
    li =[USER].concat(li)

  write ACL, li.join('\n')+'\n'


ENV = join ROOT, 'env'
env = parse read ENV

gen env.REDIS_PASSWORD,''
gen env.MQ_PASSWORD,'_mq'
