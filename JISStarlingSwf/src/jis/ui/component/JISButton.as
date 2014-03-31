package jis.ui.component
{
	import jis.ui.JISUIMovieClipManager;
	import jis.util.JISEventUtil;
	
	import lzm.starling.swf.display.SwfMovieClip;
	
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	
	/**
	 * 按钮，实际上就是包装了一个SwfMovieClip，每帧代表的含义参考静态DEFULT、GLIDE、CLICK、SELECTED、ENABLE所代表的帧数
	 * @author jiessie 2013-11-19
	 */
	public class JISButton extends JISUIMovieClipManager
	{
		/** 按钮点击时间 */
		public static const BUTTON_CLICK:String = "click";
		
		/** 默认状态 */
		public static const DEFULT:int = 1;
		/** 鼠标划过 */
		public static const GLIDE:int = 2;
		/** 鼠标按下 */
		public static const CLICK:int = 3;
		/** 选中状态 */
		public static const SELECTED:int = 4;
		/** 不可用状态 */
		public static const ENABLE:int = 5;
		public var _Text:TextField;
		public var _BackMovie:SwfMovieClip;
		/** 当前状态 */
		protected var state:int = DEFULT;
		private var lock:Boolean = false;
		
		private var isDown:Boolean = false;
		/** 是否复选按钮模式 */
		private var hasCheckBox:Boolean = false;
		
		private var _clickHandler:Function;
		
		public function JISButton(movie:SwfMovieClip = null,hasCheckBox:Boolean = false)
		{
			super();
			this.hasCheckBox = hasCheckBox;
			if(movie) setCurrDisplay(movie);
		}
		
		public override function setCurrDisplay(display:DisplayObject):void
		{
			super.setCurrDisplay(display);
			setState(DEFULT);
			JISEventUtil.addDisplayMouseEventHandler(display,onMouseHandler,TouchPhase.BEGAN,TouchPhase.ENDED);
		}
		
		private function onMouseHandler(type:String):void
		{
			if(type == TouchPhase.BEGAN)
			{
				if(!hasCheckBox) setState(CLICK);
				else setState(state == DEFULT ? SELECTED:DEFULT,true);
				isDown = true;
			}else if(!hasCheckBox)
			{
				setState(DEFULT);
				if(isDown)
				{
					this.dispatchEvent(new Event(BUTTON_CLICK));
					if(this._clickHandler != null) this._clickHandler.call();
					onClickHandler();
				}
				isDown = false;
			}
		}
		
		protected function onClickHandler():void {}
		
		/** 设置显示文本 */
		public function setText(text:String):void
		{
			if(this._Text) this._Text.text =text;
		}
		
		/** 是否启用按钮 */
		public function setEnable(value:Boolean,hasUpdateBtn:Boolean = true):void
		{
			if(hasUpdateBtn)
			{
				setState(value ? DEFULT:ENABLE,true);
			}
			if(value)
			{
				JISEventUtil.addDisplayMouseEventHandler(display,onMouseHandler,TouchPhase.BEGAN,TouchPhase.ENDED);
			}else
			{
				JISEventUtil.removeDisplayClickEventHandler(display);
			}
		}
		
		/** 设置选中状态，如果为选中状态的时候，点击与切换将不会改变按钮状态 */
		public function setSelected(selected:Boolean):void
		{
			setState(selected ? SELECTED:DEFULT,true);
		}	
		
		/** 
		 * 设置按钮状态，参考LButton静态成员，如果当前为选中状态的话，将不会切换 
		 * @param state 状态
		 * @param hasCoerce 是否强制切换，如果为true，将会忽略选中状态，否则如果为选中状态将会不执行
		 */
		public function setState(state:int,hasCoerce:Boolean = false):void
		{
			if(!lock)
			{
				//不忽略选中状态的话，将会
				if((this.state == SELECTED || this.state == ENABLE) && !hasCoerce)
				{
					return;
				}
				
				if(getMovieClip()) getMovieClip().gotoAndStop(Math.min(state-1,getMovieClip().totalFrames-1),false);
				this.state = state;
			}
		}
		
		/** 设置锁定状态 */
		public function setLockState(state:int,lock:Boolean):void
		{
			if(!this.lock || lock)
			{
				if(getMovieClip()) getMovieClip().gotoAndStop(Math.min(state-1,getMovieClip().totalFrames-1),false);
				this.state = state;
			}
			this.lock = lock;
		}
		
		/** 获取按钮当前状态 */
		public function getState():int
		{
			return this.state;
		}
		
		/** 是否选中状态 */
		public function isSelected():Boolean { return this.state == SELECTED; }
		/** 获得影片剪辑 */
		private function getMovieClip():SwfMovieClip { return _BackMovie ? _BackMovie:movie; }
		
		public override function dispose():void
		{
			JISEventUtil.removeDisplayClickEventHandler(display);
			this._clickHandler = null;
			super.dispose();
		}
		
		/** 检查显示对象是否可以创建该类型按钮 */
		public function checkHasButton(display:DisplayObject):Boolean { return display is SwfMovieClip; }
		
		public function setClickHandler(handler:Function):void { this._clickHandler = handler; }
	}
}