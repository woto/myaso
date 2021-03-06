# encoding: utf-8

# @private
class Myaso::TokyoCabinet::Rules < Myaso::Adapter
  include TokyoCabinet

  def find id
    rules.get(id)
  end

  def set id, rule
    rules.put(id, rule)
  end

  def delete id
    rules.delete(id)
  end

  def first rule_set_id, suffix, prefix = ''
    rule_id = TDBQRY.new(rules).tap do |q|
      q.addcond('rule_set_id', TDBQRY::QCNUMEQ, rule_set_id)

      if suffix && !suffix.empty?
        q.addcond('suffix', TDBQRY::QCSTREQ, suffix)
      else
        q.addcond('suffix', TDBQRY::QCSTRRX | TDBQRY::QCNEGATE, '')
      end

      if prefix && !prefix.empty?
        q.addcond('prefix', TDBQRY::QCSTREQ, prefix)
      else
        q.addcond('prefix', TDBQRY::QCSTRRX | TDBQRY::QCNEGATE, '')
      end

      q.setlimit(1, 0)
    end.search.first

    rule_id && find(rule_id)
  end

  def has_suffix? suffix
    TDBQRY.new(rules).tap do |q|
      if suffix && !suffix.empty?
        q.addcond('suffix', TDBQRY::QCSTREQ, suffix)
      else
        q.addcond('suffix', TDBQRY::QCSTRRX | TDBQRY::QCNEGATE, '')
      end

      q.setlimit(1, 0)
    end.search.any?
  end

  def select_by_rule_set_id rule_set_id
    TDBQRY.new(rules).tap do |q|
      q.addcond('rule_set_id', TDBQRY::QCNUMEQ, rule_set_id)
    end.search
  end

  def select_by_prefix prefix, rule_set_id = nil
    TDBQRY.new(rules).tap do |q|
      if prefix && !prefix.empty?
        q.addcond('prefix', TDBQRY::QCSTREQ, prefix)
      else
        q.addcond('prefix', TDBQRY::QCSTRRX | TDBQRY::QCNEGATE, '')
      end

      if rule_set_id
        q.addcond('rule_set_id', TDBQRY::QCNUMEQ, rule_set_id)
      end
    end.search
  end

  def select_by_suffix suffix, rule_set_id = nil
    TDBQRY.new(rules).tap do |q|
      if suffix && !suffix.empty?
        q.addcond('suffix', TDBQRY::QCSTREQ, suffix)
      else
        q.addcond('suffix', TDBQRY::QCSTRRX | TDBQRY::QCNEGATE, '')
      end

      if rule_set_id
        q.addcond('rule_set_id', TDBQRY::QCNUMEQ, rule_set_id)
      end
    end.search
  end

  def size
    rules.size
  end

  protected
    def rules
      @rules ||= base.storages[:rules]
    end
end
