package jis.ui.component
{
	import flash.geom.Rectangle;
	
	import feathers.events.FeathersEventType;
	
	import lzm.starling.display.ScrollContainer;
	import lzm.util.CollisionUtils;
	
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	/**
	 * 能够滚动的Table,操作table内容的话请调用getTable()获取JISTable实例
	 * @author jiessie 2013-11-21
	 */
	public class JISScrollTable extends ScrollContainer
	{
		public static const SCROLL_TYPE_NORMAL:String = "SCROLL_TYPE_NORMAL";
		public static const SCROLL_TYPE_CELL:String = "SCROLL_TYPE_CELL";
		
		private var table:JISTable;
		private var scrollType:String = SCROLL_TYPE_NORMAL;
		
		public function JISScrollTable(tabbedCellList:Array=null, hasClickListener:Boolean=true)
		{
			super();
			table = new JISTable(tabbedCellList, hasClickListener);
			this.addScrollContainerItem(table);
			table.addEventListener(Event.CHANGE,onTableChangeHandler);
			
			addEventListener(FeathersEventType.SCROLL_COMPLETE,onScrollCompleteHandler);
		}
		
		public function getTable():JISTable { return this.table; }
		
//		/** 停留在最底端 */
//		public function toBottom():void
//		{
//			throwTo(maxHorizontalScrollPosition,maxVerticalScrollPosition,0);
//		}
		
		public override function dispose():void
		{
			if(table) table.removeFromParent(true);
			table = null;
			super.dispose();
		}
		
		/**
		 * 滚动到最下方
		 * @param time 时间(秒)
		 */ 
		public function toBottom(time:Number = 1):void
		{
			var maxWidth:int = Math.max(0,table.width - this.width);
			var maxHeight:int = Math.max(0,table.height - this.height);
			scrollToPosition(maxWidth,maxHeight,time);
		}
		
		/**
		 * 滚动到最上方
		 * @param time 时间(秒)
		 */
		public function toTop(time:Number = 1):void
		{
			scrollToPosition(0,0,time);
		}
		
		/**
		 * 滚动到指定页
		 * @param page 页数，计算方式:scroll显示的范围为一页,0为第一页
		 * @param time 时间(秒)
		 */
		public function toPage(page:int,time:Number = 1):void
		{
			var maxWPage:int = Math.ceil(table.width/this.width);
			var maxHPage:int = Math.ceil(table.height/this.height);
			
			var wPage:int = Math.min(page,maxWPage-1);
			var hPage:int = Math.min(page,maxHPage-1);
			scrollToPosition(this.width*wPage,this.height*hPage,time);
		}
		
		private function onTableChangeHandler(e:Event):void
		{
			updateShowItems();
			this.addChild(table);
		}
		
		/**
		 * 更新显示的对象
		 * */
		public override function updateShowItems():void{
			_viewPort2.x = _horizontalScrollPosition;
			_viewPort2.y = _verticalScrollPosition;
			_viewPort2.width = width;
			_viewPort2.height = height;
			
			var itemViewPort:Rectangle = new Rectangle();
			var index:int = 0;
			for each(var tableCell:JISITableCell in this.getTable().getTabbedList())
			{
				itemViewPort.x = tableCell.getDisplay().x;
				itemViewPort.y = tableCell.getDisplay().y;
				itemViewPort.width = tableCell.getDisplay().width;
				itemViewPort.height = tableCell.getDisplay().height;
				
				index++;
				
				if(CollisionUtils.isIntersectingRect(_viewPort2,itemViewPort))
				{
					if(tableCell.getDisplay().parent == null)
					{
						this.getTable().addChild(tableCell.getDisplay());
					}
				}else
				{
					//第一个与最后一个不会移除
					if(index > 1 && index < this.getTable().getTabbedList().length)
					{
						tableCell.getDisplay().removeFromParent();
					}
				}
					
//				tableCell.getDisplay().visible = CollisionUtils.isIntersectingRect(_viewPort2,itemViewPort);
			}
			
		}
		
		public function setScrollType(type:String):void
		{
			this.scrollType = type;
		}
		
		private function onScrollCompleteHandler(e:*):void{
			if(this.scrollType == SCROLL_TYPE_CELL){
				var tableCell:JISITableCell = getScrollShowCell();
				horizontalScrollPosition = tableCell.getDisplay().x;
				verticalScrollPosition = tableCell.getDisplay().y;
				
				scrollToPosition(tableCell.getDisplay().x,tableCell.getDisplay().y,1);
			}
		}
		
		public function getScrollShowCell():JISITableCell{
			_viewPort2.x = _horizontalScrollPosition;
			_viewPort2.y = _verticalScrollPosition;
			_viewPort2.width = width;
			_viewPort2.height = height;
			
			if((maxHorizontalScrollPosition != 0 && _viewPort2.x <= 0) || (maxVerticalScrollPosition != 0 && _viewPort2.y <= 0)) return this.getTable().getTabbedList()[0];
			if((maxHorizontalScrollPosition != 0 && _viewPort2.x >= maxHorizontalScrollPosition) || (maxVerticalScrollPosition != 0 && _viewPort2.y >= maxVerticalScrollPosition)) return this.getTable().getTabbedList()[this.getTable().getTabbedList().length-1];
			
			var tableCell:JISITableCell;
			var itemViewPort:Rectangle = new Rectangle();
			for each(tableCell in this.getTable().getTabbedList())
			{
				itemViewPort.x = tableCell.getDisplay().x;
				itemViewPort.y = tableCell.getDisplay().y;
				itemViewPort.width = tableCell.getDisplay().width;
				itemViewPort.height = tableCell.getDisplay().height;
				
				if(CollisionUtils.isIntersectingRect(_viewPort2,itemViewPort))
				{
					if((maxHorizontalScrollPosition != 0 && _viewPort2.x - itemViewPort.x < itemViewPort.width/2) 
						|| (maxVerticalScrollPosition != 0 && _viewPort2.y - itemViewPort.y < itemViewPort.height/2))
					{
						break;
					}
				}
			}
			return tableCell;
		}
	}
}