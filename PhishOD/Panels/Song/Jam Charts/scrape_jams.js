function jquery_cb($) {
    return success($('table tr').slice(1).map(function () {
        $this = $(this);
        $tds = $this.find('td');
        return {
		    isKey: $this.hasClass('keyversion'),
		    isNoteworthy: $this.hasClass('noteworthy'),
            date: $tds.eq(0).find('a').text(),
            length: $tds.eq(2).text(),
            notes: $tds.eq(3).text()
        };
    }).toArray());
}
