CREATE TABLE public.tickit_sales_by_category AS (WITH cat AS (
        SELECT DISTINCT e.eventid,
            c.catgroup,
            c.catname
        FROM wp_spectrum.event AS e
            LEFT JOIN wp_spectrum.category AS c ON c.catid = e.catid
    )
    SELECT cast(d.caldate AS DATE) AS caldate,
        s.pricepaid,
        s.qtysold,
        round(cast(s.pricepaid AS DECIMAL(8,2)) * s.qtysold, 2) AS sale_amount,
        cast(s.commission AS DECIMAL(8,2)) AS commission,
        round((cast(s.commission AS DECIMAL(8,2)) / (cast(s.pricepaid AS DECIMAL(8,2)) * s.qtysold)) * 100, 2) AS commission_prcnt,
        e.eventname,
        concat(u1.firstname, u1.lastname) AS seller,
        concat(u2.firstname, u2.lastname) AS buyer,
        c.catgroup,
        c.catname
    FROM wp_spectrum.sales AS s
        LEFT JOIN wp_spectrum.listing AS l ON l.listid = s.listid
        LEFT JOIN wp_spectrum.user AS u1 ON u1.userid = s.sellerid
        LEFT JOIN wp_spectrum.user AS u2 ON u2.userid = s.buyerid
        LEFT JOIN wp_spectrum.event AS e ON e.eventid = s.eventid
        LEFT JOIN wp_spectrum.tbldate AS d ON d.dateid = s.dateid
        LEFT JOIN cat AS c ON c.eventid = s.eventid)