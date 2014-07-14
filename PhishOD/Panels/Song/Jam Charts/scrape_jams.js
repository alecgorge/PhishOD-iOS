function jquery_cb($) {
    return success($('#tblMain tr').slice(2).map(function () {
        $this = $(this);
        $tds = $this.find('td');
        return {
            is_bold: $tds.eq(1).hasClass('s5'),
            date: $tds.eq(1).text(),
            length: $tds.eq(2).text(),
            notes: $tds.eq(3).text()
        };
    }).toArray());
}
