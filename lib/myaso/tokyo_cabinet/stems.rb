# encoding: utf-8

# @private
class Myaso::TokyoCabinet::Stems < Myaso::Adapter
  include TokyoCabinet
  
  def find id
    stems.get(id)
  end

  def set id, rule
    stems.put(id, rule)
  end

  def delete id
    stems.delete(id)
  end

  def find_by_stem_and_rule_set_id stem, rule_set_id
    stem_id = TDBQRY.new(stems).tap do |q|
      if stem && !stem.empty?
        q.addcond('stem', TDBQRY::QCSTREQ, stem)
      else
        q.addcond('stem', TDBQRY::QCSTRRX | TDBQRY::QCNEGATE, '')
      end

      q.addcond('rule_set_id', TDBQRY::QCNUMEQ, rule_set_id)

      q.setlimit(1, 0)
    end.search.first

    stem_id && find(stem_id)
  end

  def has_stem? stem, rule_set_id = nil
    TDBQRY.new(stems).tap do |q|
      if stem && !stem.empty?
        q.addcond('stem', TDBQRY::QCSTREQ, stem)
      else
        q.addcond('stem', TDBQRY::QCSTRRX | TDBQRY::QCNEGATE, '')
      end

      if rule_set_id
        q.addcond('rule_set_id', TDBQRY::QCNUMEQ, rule_set_id)
      end
      q.setlimit(1, 0)
    end.search.any?
  end

  def select stem
    TDBQRY.new(stems).tap do |q|
      if stem && !stem.empty?
        q.addcond('stem', TDBQRY::QCSTREQ, stem)
      else
        q.addcond('stem', TDBQRY::QCSTRRX | TDBQRY::QCNEGATE, '')
      end
    end.search
  end

  def select_by_ending ending, rule_set_id = nil
    TDBQRY.new(stems).tap do |q|
      q.addcond('stem', TDBQRY::QCSTREW, ending)

      if rule_set_id
        q.addcond('rule_set_id', TDBQRY::QCNUMEQ, rule_set_id)
      end
    end.search
  end

  def size
    stems.size
  end

  protected
    def stems
      @stems ||= base.storages[:stems]
    end
end
