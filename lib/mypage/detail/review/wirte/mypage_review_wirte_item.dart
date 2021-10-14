import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import 'mypage_review_write_detail.dart';

class MyPageReviewWirteItem extends StatefulWidget {

  String token, mbrId, jobId, jobTtl, junHan, myId, opId, myNicNm, opNicNm, revCtn;
  int index, totMbrGrd, mbrGrd;
  MyPageReviewWirteItem(this.token, this.index, this.mbrId, this.jobId, this.jobTtl, this.junHan, this.myId, this.opId, this.myNicNm, this.opNicNm, this.revCtn, this.totMbrGrd, this.mbrGrd);
  @override
  _MyPageReviewWirteItemState createState() => _MyPageReviewWirteItemState();
}

class _MyPageReviewWirteItemState extends State<MyPageReviewWirteItem> {

  String jobIts, revCtn, token;
  bool isDisposed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageReviewWriteDetail( jobId:widget.jobId, junHan:  widget.junHan, myId: widget.myId, myNicNm: widget.myNicNm, opId: widget.opId, opNicNm: widget.opNicNm, revCtn: widget.revCtn, totMbrGrd : widget.totMbrGrd, mbrGrd: widget.mbrGrd ))),
      child: Card(
        elevation: widget.index == 0 ? 8 : 4,
        shape: widget.index != 0  ? RoundedRectangleBorder( borderRadius: BorderRadius.circular(4),  side: BorderSide( color: Colors.grey[400], )) : null,
        margin: EdgeInsets.only(bottom: 10, left: 1, right: 1),
        child: Padding(
          padding: EdgeInsets.all(defaultSize * 1.3),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: defaultSize),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.jobTtl ?? '일거리'),
                  ],
                ),
              ),
              Row(
                children: [
                  junView(defaultSize, widget.junHan),
                  SizedBox( width: defaultSize * 2, ),
                  Container(
                    child: Text(
                      (widget.mbrGrd == 9) ? '후기 작성 하기' : '후기 수정 / 삭제' ,
                      style: TextStyle(color: Colors.green, fontSize: defaultSize * 1.3, fontWeight: FontWeight.bold),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    hanView(defaultSize, widget.junHan),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget junView(defaultSize, junHan){
    print('junHan ========================== $junHan');
    return Container(
      child: Text(
        '주니 : ${junHan == "J" ? widget.myNicNm : widget.opNicNm}',
        style: TextStyle(color: Colors.blue, fontSize: defaultSize * 1.4, fontWeight: FontWeight.bold),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        // color: Colors.orange[50],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget hanView(defaultSize, junHan){
    print('junHan ========================== $junHan');
    return Container(
      child: Text(
        '하니 : ${junHan == "H" ? widget.myNicNm : widget.opNicNm}',
        style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.4, fontWeight: FontWeight.bold),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        // color: Colors.orange[50],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}