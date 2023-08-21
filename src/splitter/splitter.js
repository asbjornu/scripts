'use strict';

(function() {
  const split = function(post, maxChunkLength, hashtags) {
    const paragraphs = post.split('\n').filter(function(p) { return p.trim() !== ''; });
    const chunks = [];

    for (let i = 0; i < paragraphs.length; i++) {
      let paragraph = paragraphs[i];
      paragraph += ' ' + hashtags + ' ' + (i + 1) + '/' + paragraphs.length;
      paragraph = paragraph.trim();

      if (paragraph <= maxChunkLength) {
        chunks.push(paragraph);
        continue;
      }

      const words = paragraph.split(' ');
      let chunk = '';

      for (let word of words) {
        if (chunk.length + word.length + 1 > maxChunkLength) {
          chunks.push(chunk);
          chunk = '';
        }

        chunk += word + ' ';
      }

      chunks.push(chunk);
    }

    return chunks;
  };

  document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementsByTagName('form')[0];
    const main = document.getElementsByTagName('main')[0];
    const hashtags = document.getElementById('hashtags');
    const post = document.getElementById('post');
    const length = document.getElementById('length')

    form.addEventListener('submit', function(e) {
      e.preventDefault();
      const ol = document.createElement('ol')
      const maxChunkLength = parseInt(length.value, 10);
      const chunks = split(post.value, maxChunkLength, hashtags.value);

      for (let chunk of chunks) {
        const li = document.createElement('li');
        li.innerText = chunk;
        ol.appendChild(li);
      }

      main.appendChild(ol);

      return false;
    });
  });
})();
