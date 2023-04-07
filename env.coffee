#!/usr/bin/env coffee

> path > dirname join
  @w5/uridir
  @w5/write
  @w5/read
  fs > existsSync
  fs/promises > opendir
  nanoid > nanoid
  os > cpus
  dotenv > parse

ROOT = uridir(import.meta)
ENV = join(
  ROOT
  'wac/env'
)

if existsSync ENV
  pre = parse read ENV
else
  pre = {}

host = 'wac.tax'

MAIL_USER = 'i@'+host
MAIL_FROM = MAIL_USER
REDIS_HOST = 'redis'
REDIS_PORT = 9998
PG_HOST='pg'
PG_DB=host
PG_USER=host
PG_PORT=9997
PG_POOL_CONN=32
PG_SSL= 'false'
PG_PASSWORD=nanoid()

data = {
  PG_HOST
  PG_DB
  PG_USER
  PG_PORT
  PG_POOL_CONN
  PG_SSL
  PG_PASSWORD
  PG_URI:"$PG_USER:$PG_PASSWORD@$PG_HOST:$PG_PORT/$PG_DB"

  REDIS_DB:0
  REDIS_USER:'default'
  REDIS_PASSWORD:nanoid()

  REDIS_HOST
  REDIS_PORT
  REDIS_HOST_PORT: '$REDIS_HOST:$REDIS_PORT'

  MAIL_SECURE: true
  MAIL_HOST : 'smtp.'+host
  MAIL_PORT : 465
  MAIL_USER
  MAIL_FROM
  MAIL_PASSWORD: "password"

  HTTP_CPU_NUM:cpus().length
}

txt = []
namespace = ''
for [k,v] from Object.entries data
  ns = k[...k.indexOf('_')]
  if namespace and ns != namespace
    txt.push ''
  namespace = ns

  txt.push "#{k}=#{pre[k] or v}"

if not 'DEBUG' of pre
  txt.push '# DEBUG=1'

await write ENV, txt.join('\n')+'\n'

for await fp from await opendir ROOT
  if not fp.isDirectory()
    continue
  docker = join(ROOT,fp.name,'docker-compose.yml')
  if not existsSync docker
    continue

  li = read(docker).split('\n')
  txt = []
  state = 0
  for i from li
    i = i.trimEnd()
    t = i.trimStart()
    if state == 2
      if t.endsWith ':'
        state = 3
        txt.push i
    else
      txt.push i
    if state == 1
      if t == 'environment:'
        state = 2
        for k from Object.keys data
          txt.push "      #{k}: ${#{k}}"
    else if t=='api:'
      state = 1

  await write docker, txt.join('\n')

