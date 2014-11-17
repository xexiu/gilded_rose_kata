def update_quality(items)
  QualityUpdater.new.update(items)
end

class QualityUpdater
  def update(items)
    items.each do |item|
      update_one(item)
    end
  end

  private

  class StandardQualityUpdater
    def update(item)
      update_quality(item)
      update_sell_in(item)
    end

    def update_quality(item)
      if item.sell_in <= 0
        bump(item, -2)
      else
        bump(item, -1)
      end
    end

    def update_sell_in(item)
      item.sell_in -= 1
    end

    def bump(item, amount)
      item.quality += amount
      item.quality = 50 if item.quality > 50
      item.quality = 0 if item.quality < 0
    end
  end

  class NoopQualityUpdater < StandardQualityUpdater
    def update_quality(item)
    end
    def update_sell_in(item)
    end
  end

  class BrieQualityUpdater < StandardQualityUpdater
    def update_quality(item)
      if item.sell_in <= 0
        bump(item, 2)
      else
        bump(item, 1)
      end
    end
  end

  class BackstagePassQualityUpdater < StandardQualityUpdater
    def update_quality(item)
      if item.sell_in > 10
        bump(item, 1)
      elsif item.sell_in > 5
        bump(item, 2)
      elsif item.sell_in > 0
        bump(item, 3)
      else
        item.quality = 0
      end
    end
  end

  class ConjuredItemQualityUpdater < StandardQualityUpdater
    def update_quality(item)
      if item.sell_in <= 0
        bump(item, -4)
      else
        bump(item, -2)
      end
    end
  end

  UPDATERS = [
    [/^Sulfuras, Hand of Ragnaros$/, NoopQualityUpdater.new],
    [/^Aged Brie$/, BrieQualityUpdater.new],
    [/^Backstage passes to a TAFKAL80ETC concert$/, BackstagePassQualityUpdater.new],
    [/^Conjured /, ConjuredItemQualityUpdater.new],
  ]

  def update_one(item)
    updater_for(item).update(item)
  end

  def updater_for(item)
    pair = UPDATERS.detect { |re, handler| re =~ item.name }
    handler = pair ? pair[1] : standard_updater
  end

  def standard_updater
    @standard_handler ||= StandardQualityUpdater.new
  end
end


# DO NOT CHANGE THINGS BELOW -----------------------------------------

Item = Struct.new(:name, :sell_in, :quality)

# We use the setup in the spec rather than the following for testing.
#
# Items = [
#   Item.new("+5 Dexterity Vest", 10, 20),
#   Item.new("Aged Brie", 2, 0),
#   Item.new("Elixir of the Mongoose", 5, 7),
#   Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
#   Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
#   Item.new("Conjured Mana Cake", 3, 6),
# ]

