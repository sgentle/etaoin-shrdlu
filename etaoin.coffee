textarea = document.getElementById 'etaoin'

Promise.all([
  fetch('letter_bigrams.txt').then((x) -> x.text())
  fetch('word_bigrams.txt').then((x) -> x.text())
])
.then ([letterdata, worddata]) ->
  letters = {}
  for l in letterdata.split('\n') when l
    (letters[l[0]] ||= []).push(l[1])


  words = {}
  for w in worddata.split('\n') when w
    [word1, word2] = w.split('\t')
    (words[word1] ||= []).push(word2)

  console.log 'initial letters', letters['^']
  console.log 'initial letters', words['<S>']


  currentletter = '^'
  currentword = ''
  restart = ->
    currentletter = '^'
    currentword = ''

  next = (l) ->
    return restart() if l is ' '
    rank = letters[currentletter].indexOf(l)
    return restart() unless rank?
    currentword = words[currentword or "<S>"]?[rank]
    return restart() unless currentword
    oldletter = currentletter
    currentletter = l
    console.log "old letter", oldletter, "new letter", currentletter, "rank", rank, "new word", currentword
    currentword

  textarea.value += " Ready!\n"

  text = []
  caps = true
  textarea.addEventListener 'keypress', (ev) ->
    ev.preventDefault()
    key = (ev.key or String.fromCharCode(ev.charCode)).toLowerCase()
    val = next(key)
    if !val
      if text[text.length - 1] and text[text.length - 1].slice(-1) isnt '.'
        text[text.length - 1] += '.'
      caps = true
    else if caps
      caps = false
      text.push val[0].toUpperCase() + val.slice(1)
    else if val.length is '1'
      text.push val.toUpperCase()
    else
      text.push val

    textarea.scrollTop = textarea.scrollHeight

    textarea.value = text.join(' ')