require 'yaml'

module Create
  def create_single_insert(insert_obj)
    name, type = insert_obj['name'], insert_obj['type']
    "#{name} #{type} #{'unique' if insert_obj.key?('unique')}"
  end

  def create_single_foreign(foreign_obj)
    name, table, key = ['name', 'table', 'key'].map{ |x| foreign_obj[x] }
    "foreign key (#{name}) references #{table}(#{key})"
  end

  def create_single_index(index_obj)
    name, table, key = ['name', 'table', 'key'].map{ |x| index_obj[x] }
    "create index if not exists #{name} on #{table + '(' + key + ');'}"
  end

  def create_insert_str(columns_obj, foreign_obj, indexes_obj)
    insert_statements = ['id integer primary key autoincrement']
    insert_statements +=  columns_obj.map{ |x| create_single_insert(x) }
    insert_statements += foreign_obj.map{ |x| create_single_foreign(x) } if foreign_obj

    insert_statements = "(#{insert_statements.join(',')});"

    insert_statements +=  indexes_obj.map { |x| create_single_index(x) }.join(" ") if indexes_obj

    insert_statements
  end

  def build_create_query(obj)
    name = obj['name']
    create = "create table if not exists #{name}"
    insert = create_insert_str(obj['columns'], obj['foreign'], obj['indexes'])
    create + insert
  end

  def create_tables(obj)
    obj["tables"].map{ |x| build_create_query(x) }
  end
end

module Insert

  def create_insert_lambda(obj)
    table = obj['name']
    names = obj['columns'].map{ |x| x["name"] }

    lambda do |*args|
      "insert into #{table} VALUES (#{args.join(",")});"
    end
  end

  def create_select_id_lambda(obj)
    table = obj['name']
    select_on = obj['select_on']
    lambda do |key|
      "select id from  #{table} where #{select_on} = #{key};"
    end
  end

  def create_lambdas(obj)
    obj["tables"].map do |x|
      {
        name: x["name"],
        insert: create_insert_lambda(x),
        select: create_select_id_lambda(x)
      }
    end
  end
end

class Query
  extend Create
  extend Insert

  def initialize(yaml_path)
    yaml = YAML.load_file('schema.yaml')

    self.class.create_tables(yaml)
    create_methods(yaml)
  end

  def create_methods(yaml)
    lambdas = self.class.create_lambdas(yaml)

    lambdas.each do |x|
      insert_name =  ("insert_" + x[:name]).to_sym

      self.class.send(:define_method, insert_name) do |*args|
        x[:insert].call(*args)
      end

      select_name =  ("select_" + x[:name]).to_sym

      self.class.send(:define_method, select_name) do |val|
        x[:select].call(val)
      end
    end
  end
end
