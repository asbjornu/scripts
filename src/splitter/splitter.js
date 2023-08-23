'use strict';

(function() {
  const findSplitIndex = function(primaryPunctuationIndices, secondaryPunctuationIndices, maxChunkLength, trailers) {
    const minChunkLength = maxChunkLength / 2;
    const trailerLength = trailers.length > 0 ? trailers.length + 2 : 0;

    const punctuationWithinThreshold = function(punctuationIndices) {
      for (let i = punctuationIndices.length - 1; i >= 0; i--) {
        const punctuationIndex = punctuationIndices[i];
        const punctuationWithTrailerLength = punctuationIndex + trailerLength;

        if (punctuationWithTrailerLength < maxChunkLength && punctuationIndex > minChunkLength) {
          return punctuationIndex;
        }
      }

      return -1;
    }

    const primaryPunctuationIndex = punctuationWithinThreshold(primaryPunctuationIndices);
    if (primaryPunctuationIndex > -1) {
      return primaryPunctuationIndex;
    }

    const secondaryPunctuationIndex = punctuationWithinThreshold(secondaryPunctuationIndices);
    if (secondaryPunctuationIndex > -1) {
      return secondaryPunctuationIndex;
    }

    // TODO: We should keep track of whitespace as a fallback for when
    //       punctuation can't be found within the threshold so we don't
    //       perform the split in the middle of a word.
    return maxChunkLength;
  };

  const split = function(post, maxChunkLength, trailers) {
    const chunks = [];
    const primaryPunctuations = ['.', '?', '!'];
    const secondaryPunctuations = [',', ';', ':'];
    const primaryPunctuationIndices = [];
    const secondaryPunctuationIndices = [];
    const trailerLength = trailers.length > 0 ? trailers.length + 2 : 0;
    let lastPunctuationIndex = -1;

    for (let i = 0; i < post.length; i++) {
      const character = post[i];

      if (primaryPunctuations.includes(character)) {
        lastPunctuationIndex = i;
        primaryPunctuationIndices.push(lastPunctuationIndex);
      } else if (secondaryPunctuations.includes(character)) {
        lastPunctuationIndex = i;
        secondaryPunctuationIndices.push(lastPunctuationIndex);
      }

      if ((i + trailerLength) < maxChunkLength) {
        continue;
      }

      const splitIndex = findSplitIndex(primaryPunctuationIndices,
                                        secondaryPunctuationIndices,
                                        maxChunkLength,
                                        trailers);

      const chunk  = post.substring(0, splitIndex + 1) + ' ' + trailers;
      chunks.push(chunk.trim());
      post = post.substring(splitIndex + 1);
      i = 0;
      lastPunctuationIndex = -1;
      primaryPunctuationIndices.length = 0;
      secondaryPunctuationIndices.length = 0;
    }

    if (post.trim().length > 0) {
      chunks.push(post + ' ' + trailers);
    }

    return chunks;
  };

  document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementsByTagName('form')[0];
    const main = document.getElementsByTagName('main')[0];
    const trailers = document.getElementById('trailers');
    const post = document.getElementById('post');
    const length = document.getElementById('length');

    form.addEventListener('submit', function(e) {
      e.preventDefault();

      let ol = document.getElementById('chunks');
      if (!ol) {
        ol = document.createElement('ol');
        ol.setAttribute('id', 'chunks');
        main.appendChild(ol);
      } else {
        while (ol.firstChild) {
          ol.removeChild(ol.firstChild);
        }
      }

      const maxChunkLength = parseInt(length.value, 10);
      const chunks = split(post.value, maxChunkLength, trailers.value);

      for (let chunk of chunks) {
        const li = document.createElement('li');
        li.innerText = chunk;
        li.setAttribute('data-length', chunk.length)
        ol.appendChild(li);
      }

      return false;
    });
  });
})();
