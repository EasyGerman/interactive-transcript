import t from './translations';

function init() {
  $('#feedback-good').click(() => recordFeedback(true));
  $('#feedback-bad').click(() => recordFeedback(false));
}

function recordFeedback(outcome) {
  let $ctn = $('#feedback-thumbs-container');
  $ctn.css('height', `${$ctn.height()}px`);
  $ctn.text(t.thanks);

  $.get({
    url: "/feedback.json",
    method: 'post',
    data: {
      outcome: outcome,
    }
  }).done(function(resp) {
  }).catch(function(err) {
    let jsonr = err.responseJSON;
    console.error("Error while sending feedback:", jsonr)
  });

}

export default { init };
