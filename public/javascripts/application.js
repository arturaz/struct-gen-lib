function show_progress() {
  $('progress').innerHTML = "<img src='/images/progress.gif' alt='' /> Kraunasi...";
}
function hide_progress() {
  $('progress').innerHTML = "";
}

document.observe('dom:loaded', function() {  
  var form = $$('form')[0];
  form.observe('submit', function(event) {
    var form = $(event.target);
    var params = form.serialize(true);
    var structurograme = $('structurograme');
    var errors = $('errors');
    var info = $('ajax_info');
    event.stop();

    show_progress();
    [info, structurograme, errors].each(function(e) { e.innerHTML = ''; });
    new Ajax.Request(form.action, {
      method: form.method,
      parameters: params,
      onSuccess: function(request) {
        hide_progress();
        var json = request.responseJSON;
        if (json['errors']) {
          errors.innerHTML = json['errors'];
          new Effect.Highlight(errors, {startcolor: '#f92222'});
        }
        else if (json['image_source']) {
          info.innerHTML = "<h2>Viskas OK</h2><p>Strūktūrogramą rasi " +
            "<a href='#structurograme'>apačioj</a> (gali tekt palaukt, kol " +
            "užsikraus).</p>Išsaugoti patogiausia naudojantis dešinio pelės " +
            "klavišo paspaudimu ant sugeneruotos struktūrogramos ir pasirinkti " +
            "'Save As'.</p>";
          new Effect.Highlight(info);
          structurograme.innerHTML = "<img src='" + 
            json['image_source'] + "' alt='Struktūrograma' />";
        }
      }
    });
  });
});
