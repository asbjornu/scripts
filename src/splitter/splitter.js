'use strict';

(function() {
  const findSplitIndex = function(primaryPunctuationIndices, secondaryPunctuationIndices, maxChunkLength, trailerLength) {
    const minChunkLength = maxChunkLength / 2;

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

  const findTrailerLength = function(postLength, maxChunkLength, trailers, numbering) {
    let trailerLength = trailers.trim().length > 0 ? trailers.length + 2 : 0;

    if (numbering) {
      const approximateNumberOfChunks = postLength / maxChunkLength;
      const numberOfDigits = Math.floor(Math.log10(approximateNumberOfChunks)) + 1;

      trailerLength += (numberOfDigits * 2) + 1;
    }

    return trailerLength;
  };

  const appendTrailers = function(chunks, trailers, numbering) {
    return chunks.map(function(chunk, index) {
      const t = (function(t) {
        if (numbering) {
          const chunkNumber = index + 1;
          return `${chunkNumber}/${chunks.length} ${t}`;
        }

        return t;
      })(trailers);

      return `${chunk}\n\n${t}`.trim();
    });
  };

  const isSentenceTerminator = function(post, index, punctuations) {
    const character = post[index];

    if (!punctuations.includes(character)) {
      return false;
    }

    // If the found punctuation is the last character of the post,
    // we can assume that the punctuation is a sentence terminator.
    if (post.length <= (index + 1)) {
      return true;
    }

    // If the next character of the found punctuation is a whitespace,
    // we can assume that the punctuation is a sentence terminator and not
    // part of a URL or similar.
    if (/\s/.test(post[index + 1])) {
      return true;
    }

    return false;
  };

  const split = function(post, maxChunkLength, trailers, numbering) {
    const chunks = [];
    const primaryPunctuations = ['.', '?', '!'];
    const secondaryPunctuations = [',', ';', ':'];
    const primaryPunctuationIndices = [];
    const secondaryPunctuationIndices = [];
    const trailerLength = findTrailerLength(post.length, maxChunkLength, trailers, numbering);
    let lastPunctuationIndex = -1;

    for (let i = 0; i < post.length; i++) {
      if (isSentenceTerminator(post, i, primaryPunctuations)) {
        lastPunctuationIndex = i;
        primaryPunctuationIndices.push(lastPunctuationIndex);
      } else if (isSentenceTerminator(post, i, secondaryPunctuations)) {
        lastPunctuationIndex = i;
        secondaryPunctuationIndices.push(lastPunctuationIndex);
      }

      if ((i + trailerLength) < maxChunkLength) {
        continue;
      }

      const splitIndex = findSplitIndex(primaryPunctuationIndices,
                                        secondaryPunctuationIndices,
                                        maxChunkLength,
                                        trailerLength);

      const chunk  = post.substring(0, splitIndex + 1);
      chunks.push(chunk.trim());
      post = post.substring(splitIndex + 1);
      i = 0;
      lastPunctuationIndex = -1;
      primaryPunctuationIndices.length = 0;
      secondaryPunctuationIndices.length = 0;
    }

    if (post.trim().length > 0) {
      chunks.push(post.trim());
    }

    return appendTrailers(chunks, trailers, numbering);
  };

  document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementsByTagName('form')[0];
    const main = document.getElementsByTagName('main')[0];
    const trailers = document.getElementById('trailers');
    const post = document.getElementById('post');
    const length = document.getElementById('length');
    const numbering = document.getElementById('numbering');

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
      const chunks = split(post.value, maxChunkLength, trailers.value, numbering.checked);

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
